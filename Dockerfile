# Dockerfile Corregido para Laravel API en Render (con PostgreSQL y Nginx/PHP-FPM)

# --- 1. Etapa de Construcción (composer_install) ---
FROM composer:2 AS composer_install

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de configuración y composer
COPY composer.json composer.lock ./

# CAMBIO CLAVE 1: Instala las dependencias de PHP SIN EJECUTAR SCRIPTS de Laravel.
# El flag --no-scripts evita el error "Could not open input file: artisan"
RUN composer install --no-dev --optimize-autoloader --no-scripts

# --- 2. Etapa de Producción (production_stage) ---
FROM php:8.2-fpm-alpine AS production_stage

# Instala dependencias del sistema y extensiones de PHP.
RUN apk update && apk add --no-cache \
    nginx \
    supervisor \
    libpq \
    postgresql-client \
    # CAMBIO CLAVE 2: Añade postgresql-dev para resolver "Cannot find libpq-fe.h"
    postgresql-dev \ 
    git \
    build-base \
    libzip-dev \
    libpng-dev \
    jpeg-dev \
    # Limpieza para reducir el tamaño de la imagen
    && rm -rf /var/cache/apk/* \
    && docker-php-ext-install pdo pdo_pgsql zip gd

# Establece el directorio de trabajo al directorio de la aplicación
WORKDIR /var/www/html

# Copia la instalación de Composer y el resto del código de la aplicación
COPY --from=composer_install /app /var/www/html
COPY . .

# Copia y configura la configuración de Nginx (asumiendo que nginx.conf está en la raíz)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Configura y optimiza Laravel
RUN php artisan key:generate
RUN php artisan config:cache
RUN php artisan route:cache

# Configura los permisos de escritura para Laravel
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# Expone el puerto por defecto de Nginx
EXPOSE 80

# Comando de inicio: Ejecuta Nginx en primer plano (requiere un setup de Nginx/PHP-FPM)
CMD ["nginx", "-g", "daemon off;"]
