FROM ghcr.io/postalserver/postal:latest

# Configurar variables de entorno por defecto
ENV RAILS_ENV=production
ENV BIND_ADDRESS=0.0.0.0
ENV WEB_PORT=8080

# Crear directorio de configuración
RUN mkdir -p /config

# Script de inicialización personalizado
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/railway-entrypoint.sh"]
