#!/bin/bash
set -e

echo "🚀 Iniciando Postal para Railway..."

export BIND_ADDRESS=${BIND_ADDRESS:-0.0.0.0}
export WEB_PORT=${PORT:-8080}
export POSTAL_CONFIG_ROOT=/app/config

echo "📡 Binding: $BIND_ADDRESS:$WEB_PORT"
echo "📁 Config dir: $POSTAL_CONFIG_ROOT"

ls -la /app/config || echo "Directorio config no accesible"

echo "🔧 Usando configuración por variables de entorno..."

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
