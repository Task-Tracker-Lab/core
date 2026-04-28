#!/bin/bash

# Функция для генерации 32 символов (8-8-8-8)
gen32() {
    openssl rand -hex 16 | sed 's/\(........\)\(........\)\(........\)\(........\)/\1-\2-\3-\4/'
}

# Функция для генерации 20 символов (5-5-5-5)
gen20() {
    openssl rand -hex 10 | sed 's/\(.....\)\(.....\)\(.....\)\(.....\)/\1-\2-\3-\4/'
}

# Функция для генерации 24 символов (6-6-6-6)
gen24() {
    openssl rand -hex 12 | sed 's/\(......\)\(......\)\(......\)\(......\)/\1-\2-\3-\4/'
}

echo "Генерация форматированных секретов (via OpenSSL Hex)..."
echo "-------------------------------------------------------"

echo "POSTGRES_PASSWORD  (32 симв): $(gen32)"
echo "REDIS_PASSWORD     (24 симв): $(gen24)"
echo "MINIO_ROOT_PASS    (32 симв): $(gen32)"
echo "APP_SECRET_KEY     (20 симв): $(gen20)"

echo "-------------------------------------------------------"
echo "Формат 5-5-5-5 или 8-8-8-8 удобнее для чтения и ввода вручную."

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Генерация секретов (Manual Mode):"
    echo "POSTGRES_PASSWORD: $(gen32)"
    echo "REDIS_PASSWORD:    $(gen24)"
    echo "MINIO_ROOT_PASS:   $(gen32)"
    echo "APP_SECRET_KEY:    $(gen20)"
fi