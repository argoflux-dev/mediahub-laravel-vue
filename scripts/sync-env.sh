#!/bin/sh

echo "SYNC ENV RUNNING"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

ENV_FILE="$ROOT_DIR/.env"
FRONTEND_DIR="$ROOT_DIR/frontend"

# prod
grep '^VITE_' "$ENV_FILE" | grep -v '^VITE_APP_NAME=' > "$FRONTEND_DIR/.env.production"
APP_NAME=$(grep '^APP_NAME=' "$ENV_FILE" | cut -d '=' -f2-)
echo "VITE_APP_NAME=$APP_NAME" >> "$FRONTEND_DIR/.env.production"

# dev
cat <<EOF > "$FRONTEND_DIR/.env.development"
VITE_API_BASE_URL=http://localhost:8082
VITE_HOST=0.0.0.0
VITE_PORT=5174
VITE_HMR_HOST=localhost
VITE_HMR_PROTOCOL=ws
EOF