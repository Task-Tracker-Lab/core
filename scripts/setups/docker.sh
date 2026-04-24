#!/bin/bash -e

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN} Проверка Docker...${NC}"

if ! command -v docker &> /dev/null; then
    echo "Docker не найден. Начинаем установку..."

    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    echo -e "${GREEN}✅ Docker успешно установлен!${NC}"
else
    echo -e "${GREEN}✅ Docker уже установлен.${NC}"
fi

echo -e "${GREEN}⚙️ Настройка daemon.json...${NC}"
if [ ! -f /etc/docker/daemon.json ]; then
    sudo cp ../../deploy/daemon.json /etc/docker/daemon.json
    echo "Конфигурация скопирована. Перезапуск Docker..."
    sudo systemctl restart docker
else
    echo "daemon.json уже существует. Проверь его вручную, если нужно."
fi

echo -e "${GREEN} Проверка Docker Swarm...${NC}"
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}')

if [ "$SWARM_STATUS" != "active" ]; then
    echo "Swarm не активен. Инициализация..."
    ADVERTISE_ADDR=$(hostname -I | awk '{print $1}')
    docker swarm init --advertise-addr "$ADVERTISE_ADDR"
    echo -e "${GREEN}✅ Swarm инициализирован!${NC}"
else
    echo -e "${GREEN}✅ Swarm уже активен.${NC}"
fi

echo -e "${GREEN} Создание глобальных сетей...${NC}"
networks=("proxy" "monitoring" "app_dev_net" "app_prod_net")

for net in "${networks[@]}"; do
    if ! docker network inspect "$net" >/dev/null 2>&1; then
        docker network create --driver overlay --attachable "$net"
        echo "Сеть $net создана."
    else
        echo "Сеть $net уже существует."
    fi
done

echo -e "${GREEN} Сервер готов к деплою!${NC}"