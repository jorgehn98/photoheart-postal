echo "👤 Creando usuario admin..."
if [ ! -z "$ADMIN_EMAIL" ]; then
    cat > /tmp/create_user.rb << EOF
#!/usr/bin/env ruby
require '/opt/postal/app/config/environment'

begin
  user = User.find_by(email_address: '$ADMIN_EMAIL')
  if user.nil?
    user = User.create!(
      email_address: '$ADMIN_EMAIL',
      first_name: '$ADMIN_FNAME',
      last_name: '$ADMIN_LNAME',
      password: '$ADMIN_PASS',
      password_confirmation: '$ADMIN_PASS',
      admin: true
    )
    puts "✅ Usuario admin creado: $ADMIN_EMAIL"
  else
    puts "✅ Usuario admin ya existe: $ADMIN_EMAIL"
  end
rescue => e
  puts "❌ Error creando usuario: #{e.message}"
end
EOF

    ruby /tmp/create_user.rb
fi
