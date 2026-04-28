#!/bin/bash

echo -e "${YELLOW}=== Настройка оверлейных сетей ===${NC}"

if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" != "active" ]; then
    echo -e "${RED}❌ Ошибка: Swarm не активен. Сначала запустите инициализацию Swarm.${NC}"
    exit 1
fi

networks=("proxy" "monitoring" "gateway")

for net in "${networks[@]}"; do
    if ! docker network inspect "$net" >/dev/null 2>&1; then
        echo "Создаю сеть $net..."

        if docker network create --driver overlay --attachable "$net"; then
            echo -e "${GREEN}✅ Сеть $net успешно создана.${NC}"
        else
            echo -e "${RED}❌ Не удалось создать сеть $net. Проверьте логи Docker.${NC}"
        fi
    else
        echo -e "${NC}ℹ️ Сеть $net уже существует, пропускаю.${NC}"
    fi
done