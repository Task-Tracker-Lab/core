#!/bin/bash -e

YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\n${YELLOW}=== [2/4] Настройка Docker Daemon ===${NC}"

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SOURCE_CONFIG="$SCRIPT_DIR/../../deploy/daemon.json"
TARGET_CONFIG="/etc/docker/daemon.json"

if [ ! -f "$SOURCE_CONFIG" ]; then
    echo -e "${RED}${ERROR} Файл источника $SOURCE_CONFIG не найден!${NC}"
    exit 1
fi

if [ -f "$TARGET_CONFIG" ]; then
    if cmp -s "$SOURCE_CONFIG" "$TARGET_CONFIG"; then
        echo -e "${GREEN}${CHECK} Конфигурация уже актуальна. Изменений не требуется.${NC}"
        exit 0
    fi
    echo -e "${INFO} Обнаружены изменения в конфигурации. Обновляю..."
fi

if ! command -v jq &> /dev/null; then
    if ! dockerd --validate --config-file "$SOURCE_CONFIG" &> /dev/null; then
        echo -e "${RED}${ERROR} Ошибка синтаксиса в $SOURCE_CONFIG! Docker не сможет запуститься.${NC}"
        exit 1
    fi
else
    jq empty "$SOURCE_CONFIG" || { echo -e "${RED}${ERROR} Невалидный JSON!${NC}"; exit 1; }
fi

echo -e "${INFO} Копирование $TARGET_CONFIG..."
mkdir -p /etc/docker
cp "$SOURCE_CONFIG" "$TARGET_CONFIG"

echo -e "${INFO} Перезапуск Docker сервиса..."
if systemctl restart docker; then
    echo -e "${GREEN}${CHECK} Docker успешно перезапущен с новой конфигурацией.${NC}"
else
    echo -e "${RED}${ERROR} Docker не смог запуститься! Проверь: journalctl -xeu docker.service${NC}"
    exit 1
fi