#!/bin/bash -e

cd "$(dirname "$(readlink -f "$0")")/.."

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <stack_name1> [stack_name2] ..."
    exit 1
fi

GLOBAL_ENV=".env"

echo "------------------------------------------"
echo "Global Config: $GLOBAL_ENV"
echo "------------------------------------------"

if [ -f "$GLOBAL_ENV" ]; then
    echo "Loading global environment variables..."
    set -a
    source "$GLOBAL_ENV"
    set +a
else
    echo "Error: Global config $GLOBAL_ENV not found."
    exit 1
fi

for stack_name in "$@"; do
    STACK_PATH="deploy/$stack_name"
    COMPOSE_FILE="$STACK_PATH/compose.yaml"

    if [ ! -d "$STACK_PATH" ]; then
        echo "Warning: Stack directory $STACK_PATH not found. Skipping."
        continue
    fi

    STACK_ENV="$STACK_PATH/.env"
    if [ -f "$STACK_ENV" ]; then
        echo "Merging local .env for $stack_name..."
        export $(grep -v '^#' "$STACK_ENV" | xargs)
    fi

    echo ">>> Deploying stack: $stack_name"

    docker stack deploy \
        --with-registry-auth \
        --detach=false \
        --prune \
        --compose-file "$COMPOSE_FILE" \
        "$stack_name"

    echo "DONE: $stack_name deployed successfully."
    echo "------------------------------------------"
done