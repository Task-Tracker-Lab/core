#!/bin/bash
set -e

echo -e "\n${YELLOW}=== [3/4] Проверка Docker и Swarm ===${NC}"

if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Ошибка: Docker демон не отвечает!${NC}"
    echo -e "${YELLOW}Попробуй выполнить: systemctl status docker${NC}"
    exit 1
fi

SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}')

if [ "$SWARM_STATUS" != "active" ]; then
    echo -e "${YELLOW}Инициализация Swarm...${NC}"
    ADVERTISE_ADDR=$(hostname -I | awk '{print $1}')

    if docker swarm init --advertise-addr "$ADVERTISE_ADDR"; then
        echo -e "${GREEN}✅ Swarm успешно инициализирован на $ADVERTISE_ADDR${NC}"
    else
        echo -e "${RED}❌ Не удалось инициализировать Swarm.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Swarm уже активен.${NC}"
fi

echo -e "\n${YELLOW}=== [4/4] Настройка Overlay сетей ===${NC}"

networks=("proxy" "monitoring" "app_dev_net" "app_prod_net")

for net in "${networks[@]}"; do
    if ! docker network inspect "$net" >/dev/null 2>&1; then
        echo -e "Создаю сеть ${YELLOW}$net${NC}..."
        if docker network create --driver overlay --attachable "$net"; then
            echo -e "${GREEN}✅ Сеть $net создана.${NC}"
        else
            echo -e "${RED}❌ Ошибка при создании сети $net${NC}"
        fi
    else
        echo -e "${NC}ℹ️ Сеть $net уже существует.${NC}"
    fi
done