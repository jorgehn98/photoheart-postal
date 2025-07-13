#!/bin/bash
set -e

echo "🚀 Iniciando Postal para Railway..."

# Generar configuración automática si no existe
if [ ! -f /config/postal.yml ]; then
    echo "📝 Generando configuración automática..."
    # Aquí generamos la config basada en variables de entorno
fi

# Inicializar DB si es necesario
echo "🗄️ Verificando base de datos..."
postal initialize --if-not-exists

# Crear usuario admin si no existe
echo "👤 Verificando usuario admin..."
if [ ! -z "$ADMIN_EMAIL" ]; then
    postal make-user --email="$ADMIN_EMAIL" --password="$ADMIN_PASS" --first-name="$ADMIN_FNAME" --last-name="$ADMIN_LNAME" --if-not-exists
fi

# Iniciar servidor web
echo "🌐 Iniciando servidor web..."
exec postal web-server --bind=$BIND_ADDRESS --port=$WEB_PORT
