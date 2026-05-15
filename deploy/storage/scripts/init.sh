#!/bin/sh
set -e

echo "🚀  Starting MinIO initialization..."

echo "⏳  Waiting for MinIO to be reachable..."
until /usr/bin/mc alias set myminio http://storage:9000 "${STORAGE_ROOT_USER}" "${STORAGE_ROOT_PASSWORD}" 2>/dev/null; do
  echo "🔄  MinIO not ready, retrying in 2s..."
  sleep 2
done
echo "✅  MinIO is reachable"

if [ -z "${DOMAIN}" ] || [ "${DOMAIN}" = "" ]; then
  echo "❌  DOMAIN is not set, exiting"
  exit 1
fi

echo "📦 Ensuring bucket ${BUCKET_NAME} exists..."
/usr/bin/mc mb "myminio/${BUCKET_NAME}" --ignore-existing
echo "✅  Bucket ${BUCKET_NAME} ready"

echo "⏱  Applying lifecycle policy..."
/usr/bin/mc ilm import "myminio/${BUCKET_NAME}" < /lifecycle/tmp.json
echo "✅  Lifecycle policy applied"

replace_vars() {
  local input="$1"
  local output="/tmp/$(basename "$input")"

  while IFS= read -r line; do
    echo "${line//\$\{BUCKET_NAME\}/$BUCKET_NAME}"
  done < "$input" > "$output"

  echo "$output"
}

echo "🌐  Applying public policy..."
PROCESSED_PUBLIC=$(replace_vars /policies/public.json)
/usr/bin/mc anonymous set-json \
  "$PROCESSED_PUBLIC" \
  "myminio/${BUCKET_NAME}"
echo "✅  Public policy applied"

echo "🔧 Configuring backend user..."
PROCESSED_BACKEND=$(replace_vars /policies/backend.json)

/usr/bin/mc admin policy create \
  myminio \
  backend-policy \
  "$PROCESSED_BACKEND"

/usr/bin/mc admin user add \
  myminio \
  "${BACKEND_USER}" \
  "${BACKEND_PASSWORD}" || true

/usr/bin/mc admin policy attach \
  myminio \
  backend-policy \
  --user "${BACKEND_USER}"

echo "✅  Backend user configured"

echo "👮  Configuring console user..."
PROCESSED_CONSOLE=$(replace_vars /policies/console.json)

/usr/bin/mc admin policy create \
  myminio \
  console-policy \
  "$PROCESSED_CONSOLE"

/usr/bin/mc admin user add \
  myminio \
  "${CONSOLE_USER}" \
  "${CONSOLE_PASSWORD}" || true

/usr/bin/mc admin policy attach \
  myminio \
  console-policy \
  --user "${CONSOLE_USER}"

echo "✅  Console user configured"

echo "🔄  Enabling versioning..."
/usr/bin/mc version enable "myminio/${BUCKET_NAME}"

echo ""
echo "🎉  MinIO initialization completed!"
echo "🔗  Console: https://cdn-console.${DOMAIN}"
echo "🔗  CDN (Public): https://cdn.${DOMAIN}"

tail -f /dev/null