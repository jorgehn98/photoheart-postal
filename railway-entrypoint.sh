#!/bin/bash
set -e

echo "🚀 Iniciando Postal para Railway..."

# Configurar binding
export BIND_ADDRESS=${BIND_ADDRESS:-0.0.0.0}
export WEB_PORT=${PORT:-8080}

echo "📡 Binding: $BIND_ADDRESS:$WEB_PORT"

# Crear configuración mínima si no existe
if [ ! -f /config/postal.yml ]; then
    echo "📝 Creando configuración básica..."
    cat > /config/postal.yml << EOF
web:
  host: ${WEB_HOSTNAME:-localhost}
  protocol: ${WEB_PROTOCOL:-http}
  
main_db:
  host: ${MAIN_DB_HOST}
  port: ${MAIN_DB_PORT:-3306}
  database: ${MAIN_DB_NAME}
  username: ${MAIN_DB_USERNAME}
  password: ${MAIN_DB_PASSWORD}

message_db:
  host: ${MESSAGE_DB_HOST:-$MAIN_DB_HOST}
  port: ${MESSAGE_DB_PORT:-3306}
  database: ${MESSAGE_DB_NAME:-$MAIN_DB_NAME}
  username: ${MESSAGE_DB_USERNAME:-$MAIN_DB_USERNAME}
  password: ${MESSAGE_DB_PASSWORD:-$MAIN_DB_PASSWORD}
EOF
fi

echo "🗄️ Inicializando base de datos..."
postal initialize || echo "Base de datos ya inicializada"

echo "👤 Creando usuario admin..."
if [ ! -z "$ADMIN_EMAIL" ]; then
    postal make-user --email="$ADMIN_EMAIL" --password="$ADMIN_PASS" --first-name="$ADMIN_FNAME" --last-name="$ADMIN_LNAME" || echo "Usuario ya existe"
fi

echo "🌐 Iniciando servidor web en $BIND_ADDRESS:$WEB_PORT..."
exec postal web-server --bind="$BIND_ADDRESS" --port="$WEB_PORT"
