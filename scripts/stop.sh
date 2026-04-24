#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")/.."

ENV_TYPE=$1

if [[ ! $ENV_TYPE =~ ^(dev|prod)$ ]]; then
  echo "Использование: ./scripts/stop.sh <dev|prod>"
  exit 1
fi

echo "🛑 Останавливаем окружение: $ENV_TYPE"
echo "=============================================="

# Список стеков в обратном порядке (сначала приложения, потом базы)
stacks=("apps" "caddy" "database" "redis" "minio" "logging" "monitoring")

for stack in "${stacks[@]}"; do
    FULL_STACK_NAME="${stack}_${ENV_TYPE}"

    if docker stack ls | grep -q "$FULL_STACK_NAME"; then
        echo "Удаляем стек: $FULL_STACK_NAME..."
        docker stack rm "$FULL_STACK_NAME"
    else
        echo "ℹСтек $FULL_STACK_NAME не запущен."
    fi
done

echo "=============================================="
echo "Ждем 10 секунд для очистки ресурсов Swarm..."
sleep 10

echo "✅ Окружение $ENV_TYPE успешно остановлено."
echo "Данные в директории ./data сохранены."