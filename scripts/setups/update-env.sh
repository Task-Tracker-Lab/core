#!/bin/bash

update_env_if_empty() {
    local file=$1
    local key=$2
    local value=$3

    [ ! -f "$file" ] && touch "$file"

    if ! grep -q "^${key}=[[:alnum:]]" "$file"; then
        if grep -q "^${key}=" "$file"; then
            sed -i "s|^${key}=.*|${key}=${value}|" "$file"
        else
            echo "${key}=${value}" >> "$file"
        fi
        echo "✅ Сгенерирован новый $key"
    fi
}