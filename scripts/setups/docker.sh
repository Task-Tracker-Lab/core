#!/bin/bash -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SETUPS_DIR="$SCRIPT_DIR/setups"

echo -e "${GREEN}=== Запуск полной настройки сервера ===${NC}"

STEPS=(
    "install-docker.sh"
    "setup-daemon.sh"
    "setup-swarm.sh"
    "setup-networks.sh"
)

for step in "${STEPS[@]}"; do
    if [ -f "$SETUPS_DIR/$step" ]; then
        bash "$SETUPS_DIR/$step"
    else
        echo -e "❌ Ошибка: Не найден компонент $step"
        exit 1
    fi
done

echo -e "${GREEN}=== Все этапы пройдены! Сервер готов. ===${NC}"