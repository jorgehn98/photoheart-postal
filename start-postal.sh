#!/bin/bash
set -e

echo "🚀 Iniciando Postal Web Server..."

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
web_server:
  default_bind_address: 0.0.0.0
  default_port: 8080

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

echo "🗄️ Inicializando..."
postal initialize || echo "Ya inicializado"

echo "👤 Creando usuario admin..."
if [ ! -z "$ADMIN_EMAIL" ]; then
    cat > /tmp/create_user.rb << 'EOF'
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
    puts "✅ Usuario admin creado"
  else
    puts "✅ Usuario admin ya existe"
  end
rescue => e
  puts "❌ Error: #{e.message}"
end
EOF
    ruby /tmp/create_user.rb
fi

echo "🌐 Iniciando web server..."
exec postal web-server
