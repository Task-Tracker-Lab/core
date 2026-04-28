#!/bin/bash -e

if [ "$EUID" -ne 0 ]; then
   echo -e "${RED}❌ Ошибка: Запустите от root${NC}"
   exit 1
fi

echo -e "\n${YELLOW}=== [1/4] Установка Docker ===${NC}"
if ! command -v docker &> /dev/null; then
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo -e "${GREEN}✅ Docker установлен!${NC}"
else
    echo -e "${GREEN}✅ Docker уже в системе.${NC}"
fi