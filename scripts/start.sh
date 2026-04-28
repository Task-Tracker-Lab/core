#!/bin/bash -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$(dirname "$(readlink -f "$0")")/.."
ROOT=$(pwd)

bash "$ROOT/scripts/docker/install.sh"
bash "$ROOT/scripts/docker/daemon.sh"
bash "$ROOT/scripts/docker/swarm.sh"
bash "$ROOT/scripts/docker/networks.sh"

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "----------------------------------------------------------"
    echo "ОШИБКА: Файл конфигурации $ENV_FILE не найден!"
    echo "Перед запуском создайте его из шаблона:"
    echo "cp .env.example $ENV_FILE"
    echo "----------------------------------------------------------"
    exit 1
else
    echo "Файл конфигурации $ENV_FILE обнаружен."
fi

if [ -f "./scripts/setups/update-env.sh" ] && [ -f "./scripts/setups/passwords.sh" ]; then
    source ./scripts/setups/update-env.sh
    source ./scripts/setups/passwords.sh

    echo "Проверка конфигурации $ENV_FILE..."

    update_env_if_empty "$ENV_FILE" "DB_PASSWORD" "$(gen32)"
    update_env_if_empty "$ENV_FILE" "REDIS_PASSWORD"    "$(gen24)"
    update_env_if_empty "$ENV_FILE" "MINIO_ROOT_PASSWORD"   "$(gen32)"
else
    echo "Ошибка: Не найдены вспомогательные скрипты в ./scripts/"
    exit 1
fi

echo "Запуск ПОЛНОГО стека"
echo "=============================================="

echo "Деплой инфраструктуры..."
./scripts/deploy.sh prod database redis minio


echo "Ожидание инициализации инфраструктуры..."
sleep 5

echo "Деплой сервисов приложения..."
./scripts/deploy.sh prod apps

echo "Деплой прокси-сервера..."
./scripts/deploy.sh prod caddy


echo "=============================================="
echo "✅ Все стеки для среды production развернуты!"
echo "Проверить статус можно командой: docker stack ls"