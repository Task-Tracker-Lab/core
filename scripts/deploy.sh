#!/bin/bash -e

cd "$(dirname "$(readlink -f "$0")")/.."

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <dev|prod> <stack_name1> [stack_name2] ..."
    exit 1
fi

ENV_TYPE="$1"
shift

GLOBAL_ENV=".env.$ENV_TYPE"

echo "------------------------------------------"
echo "Target Environment: $ENV_TYPE"
echo "Global Config: $GLOBAL_ENV"
echo "------------------------------------------"

if [ -f "$GLOBAL_ENV" ]; then
    echo "Loading global environment variables..."
    export $(grep -v '^#' "$GLOBAL_ENV" | xargs)
else
    echo "Error: Global config $GLOBAL_ENV not found in $(pwd)"
    exit 1
fi

for stack_name in "$@"; do
    STACK_PATH="deploy/$stack_name"
    COMPOSE_FILE="$STACK_PATH/compose.yaml"

    if [ ! -d "$STACK_PATH" ]; then
        echo "Error: Stack directory $STACK_PATH not found. Skipping."
        continue
    fi

    echo ">>> Deploying stack: $stack_name ($ENV_TYPE)"

    STACK_ENV="$STACK_PATH/.env"
    if [ -f "$STACK_ENV" ]; then
        echo "Found local .env for $stack_name, merging..."
        export $(grep -v '^#' "$STACK_ENV" | xargs)
    fi

    FULL_STACK_NAME="${stack_name}_${ENV_TYPE}"

    docker stack deploy \
        --with-registry-auth \
        --detach=false \
        --prune \
        --compose-file "$COMPOSE_FILE" \
        "$FULL_STACK_NAME"

    echo "DONE: $FULL_STACK_NAME deployed successfully."
    echo "------------------------------------------"
done