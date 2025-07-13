#!/bin/bash
set -e

echo "🚀 Iniciando Postal para Railway..."

export BIND_ADDRESS=${BIND_ADDRESS:-0.0.0.0}
export WEB_PORT=${PORT:-8080}
export POSTAL_CONFIG_ROOT=/app/config

echo "📡 Binding: $BIND_ADDRESS:$WEB_PORT"

echo "🔑 Generando clave de firma..."
if [ ! -f /app/config/signing.key ]; then
    openssl genrsa -out /app/config/signing.key 2048
    echo "✅ Clave de firma generada"
else
    echo "✅ Usando clave existente"
fi

echo "📝 Creando configuración mínima..."
cat > /app/config/postal.yml << EOF
web:
  host: ${WEB_HOSTNAME}
  protocol: ${WEB_PROTOCOL}
  max_body_size: 14680064

main_db:
  host: ${MAIN_DB_HOST}
  port: ${MAIN_DB_PORT}
  database: ${MAIN_DB_NAME}
  username: ${MAIN_DB_USERNAME}
  password: ${MAIN_DB_PASSWORD}

message_db:
  host: ${MESSAGE_DB_HOST}
  port: ${MESSAGE_DB_PORT}
  database: ${MESSAGE_DB_NAME}
  username: ${MESSAGE_DB_USERNAME}
  password: ${MESSAGE_DB_PASSWORD}

rabbitmq:
  host: ${RABBITMQ_HOST}
  port: ${RABBITMQ_PORT}
  username: ${RABBITMQ_USERNAME}
  password: ${RABBITMQ_PASSWORD}
  vhost: ${RABBITMQ_VHOST}

dns:
  mx_records:
    - ${SMTP_HOSTNAME}
  smtp_server_hostname: ${SMTP_HOSTNAME}
  spf_include: spf.${WEB_HOSTNAME}
  return_path: rp.${WEB_HOSTNAME}
  route_domain: routes.${WEB_HOSTNAME}
  track_domain: track.${WEB_HOSTNAME}

smtp_server:
  port: ${SMTP_PORT}
  tls_enabled: ${SMTP_TLS_ENABLED}
  
general:
  use_ip_pools: false

signing:
  key_path: /app/config/signing.key
EOF

echo "🗄️ Inicializando base de datos..."
postal initialize || echo "Base de datos ya inicializada"

echo "👤 Creando usuario admin..."
if [ ! -z "$ADMIN_EMAIL" ]; then
    cat > /tmp/create_user.rb << 'EOF'
#!/usr/bin/env ruby
require '/opt/postal/app/config/environment'

begin
  user = User.find_by(email_address: ENV['ADMIN_EMAIL'])
  if user.nil?
    user = User.create!(
      email_address: ENV['ADMIN_EMAIL'],
      first_name: ENV['ADMIN_FNAME'],
      last_name: ENV['ADMIN_LNAME'],
      password: ENV['ADMIN_PASS'],
      password_confirmation: ENV['ADMIN_PASS'],
      admin: true
    )
    puts "✅ Usuario admin creado: #{ENV['ADMIN_EMAIL']}"
  else
    puts "✅ Usuario admin ya existe: #{ENV['ADMIN_EMAIL']}"
  end
rescue => e
  puts "❌ Error creando usuario: #{e.message}"
end
EOF

    ruby /tmp/create_user.rb
fi

echo "🌐 Iniciando servidor web en $BIND_ADDRESS:$WEB_PORT..."
exec postal web-server --bind="$BIND_ADDRESS" --port="$WEB_PORT"
