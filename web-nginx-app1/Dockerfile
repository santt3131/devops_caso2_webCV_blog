# =============================================================================
# Dockerfile - Servidor web NGINX con TLS y autenticación básica
# =============================================================================
# La imagen incluye lo necesario para el servicio:
#   - Contenido HTML a mostrar.
#   - Certificado x.509 autofirmado (generado durante el build).
#   - Credenciales de usuario (htpasswd) para autenticación básica.
# =============================================================================

# Usa la versión ligera y oficial de Nginx basada en Alpine Linux
FROM nginx:stable-alpine

# Instala openssl para criptografía y apache2-utils para gestionar contraseñas
RUN apk add --no-cache openssl apache2-utils

# -----------------------------------------------------------------------------
# 1. Certificado x.509 autofirmado (válido 365 días).
# -----------------------------------------------------------------------------
# Crea la carpeta de certificados y genera el SSL autofirmado válido por 365 días
RUN mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/server.key \
    -out /etc/nginx/certs/server.crt \
    -subj "/C=ES/ST=Catalunya/L=Barcelona/O=UNIR/OU=SantiDevOps/CN=localhost"


# -----------------------------------------------------------------------------
# 2. Credenciales de autenticación básica
# Definimos los argumentos que recibiremos desde fuera al compilar
ARG HTTP_USER
ARG HTTP_PASS
# Crea el usuario y contraseña cifrada en el archivo .htpasswd como lo menciona 
# en el documento
# -----------------------------------------------------------------------------
RUN htpasswd -cb /etc/nginx/.htpasswd ${HTTP_USER} ${HTTP_PASS}


# -----------------------------------------------------------------------------
# 3. Configuración de Nginx y contenido web.
# -----------------------------------------------------------------------------
# Copio tu archivo de configuración personalizado de Nginx hacia el contenedor
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copio el archivo HTML con el diseño de tu web dentro del contenedor
COPY index.html /usr/share/nginx/html/index.html

# Copio las carpetas de diseño y recursos para que la web se vea perfecta
COPY styles/ /usr/share/nginx/html/styles/
COPY images/ /usr/share/nginx/html/images/
COPY index.js /usr/share/nginx/html/index.js

# Informa a Podman que el contenedor expondrá el tráfico seguro por el puerto 443
EXPOSE 443

# Ejecuta Nginx en primer plano para mantener el contenedor activo y corriendo
CMD ["nginx", "-g", "daemon off;"]