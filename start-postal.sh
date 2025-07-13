#!/bin/bash
set -e

echo "🚀 Iniciando Postal para Railway..."

# Configurar variables
export BIND_ADDRESS=${BIND_ADDRESS:-0.0.0.0}
export WEB_PORT=${PORT:-8080}
export POSTAL_CONFIG_ROOT=/app/config

echo "📡 Binding: $BIND_ADDRESS:$WEB_PORT"
echo "📁 Config dir: $POSTAL_CONFIG_ROOT"

# Verificar permisos
ls -la /app/config || echo "Directorio config no accesible"

# Solo usar variables de entorno (sin archivo de configuración)
echo "🔧 Usando configuración por variables de entorno..."

echo "🗄️ Inicializando base de datos..."
postal initialize || echo "Base de datos ya inicializada"

echo "👤 Creando usuario admin..."
if [ ! -z "$ADMIN_EMAIL" ]; then
    postal make-user --email="$ADMIN_EMAIL" --password="$ADMIN_PASS" --first-name="$ADMIN_FNAME" --last-name="$ADMIN_LNAME" || echo "Usuario ya existe"
fi

echo "🌐 Iniciando servidor web en $BIND_ADDRESS:$WEB_PORT..."
exec postal web-server --bind="$BIND_ADDRESS" --port="$WEB_PORT"

echo "🌐 Iniciando servidor web en $BIND_ADDRESS:$WEB_PORT..."
exec postal web-server --bind="$BIND_ADDRESS" --port="$WEB_PORT"
