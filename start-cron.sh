#!/bin/bash
set -e

echo "⏰ Iniciando Postal Cron..."

export POSTAL_CONFIG_ROOT=/app/config
export RAILS_ENVIRONMENT=production

echo "📁 Configurando directorio..."
mkdir -p /tmp/postal-config
chmod 755 /tmp/postal-config

echo "🔑 Generando clave de firma..."
if [ ! -f /tmp/postal-config/signing.key ]; then
    openssl genrsa -out /tmp/postal-config/signing.key 2048
    chmod 600 /tmp/postal-config/signing.key
    echo "✅ Clave de firma generada"
else
    echo "✅ Usando clave existente"
fi

echo "📝 Creando configuración..."
cat > /tmp/postal-config/postal.yml << EOF
web:
  host: ${WEB_HOSTNAME:-mail.photoheart.app}
  protocol: ${WEB_PROTOCOL:-https}

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

rabbitmq:
  host: ${RABBITMQ_HOST}
  port: ${RABBITMQ_PORT:-5672}
  username: ${RABBITMQ_USERNAME}
  password: ${RABBITMQ_PASSWORD}
  vhost: ${RABBITMQ_VHOST}

signing:
  key_path: /tmp/postal-config/signing.key
EOF

export POSTAL_CONFIG_ROOT=/tmp/postal-config

echo "🕐 Iniciando cron..."
exec postal cron
