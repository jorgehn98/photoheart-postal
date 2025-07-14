#!/bin/bash
set -e

echo "🔧 Iniciando Postal Worker..."

export POSTAL_CONFIG_ROOT=/tmp/postal-config
export RAILS_ENVIRONMENT=production

mkdir -p /tmp/postal-config
chmod 755 /tmp/postal-config

echo "🔑 Generando clave de firma..."
if [ ! -f /tmp/postal-config/signing.key ]; then
    openssl genrsa -out /tmp/postal-config/signing.key 2048
    chmod 600 /tmp/postal-config/signing.key
fi

echo "📝 Creando configuración v3..."
cat > /tmp/postal-config/postal.yml << EOF
worker:
  default_health_server_bind_address: 0.0.0.0
  default_health_server_port: 9090
  threads: 2

main_db:
  host: ${MAIN_DB_HOST}
  port: ${MAIN_DB_PORT:-3306}
  database: ${MAIN_DB_NAME}
  username: ${MAIN_DB_USERNAME}
  password: ${MAIN_DB_PASSWORD}

message_db:
  host: ${MESSAGE_DB_HOST}
  port: ${MESSAGE_DB_PORT:-3306}
  database: ${MESSAGE_DB_NAME}
  username: ${MESSAGE_DB_USERNAME}
  password: ${MESSAGE_DB_PASSWORD}

general:
  web_hostname: ${WEB_HOSTNAME:-mail.photoheart.app}
  web_protocol: ${WEB_PROTOCOL:-https}

signing:
  key_path: /tmp/postal-config/signing.key
EOF

echo "⚙️ Iniciando worker..."
exec postal worker
