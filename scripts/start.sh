#!/bin/bash -e

if [ -f "./setups/docker.sh" ]; then
    echo "Проверка окружения (Docker/Swarm/Networks)..."
    ./setups/docker.sh
else
    echo "Внимание: ./setups/docker.sh не найден, пропускаем установку."
fi

cd "$(dirname "$(readlink -f "$0")")/.."

ENV_TYPE=$1

if [[ ! $ENV_TYPE =~ ^(dev|prod)$ ]]; then
  echo "Использование: ./scripts/start.sh <dev|prod>"
  exit 1
fi

echo "Запуск ПОЛНОГО стека для среды: $ENV_TYPE"
echo "=============================================="

echo "Деплой инфраструктуры..."
./scripts/deploy.sh "$ENV_TYPE" database redis minio


echo "Ожидание инициализации инфраструктуры..."
sleep 5

echo "Деплой прокси-сервера..."
./scripts/deploy.sh "$ENV_TYPE" caddy

echo "Деплой сервисов приложения..."
./scripts/deploy.sh "$ENV_TYPE" apps

echo "=============================================="
echo "✅ Все стеки для среды $ENV_TYPE развернуты!"
echo "Проверить статус можно командой: docker stack ls"