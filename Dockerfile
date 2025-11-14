# ... (Etapa de Construcción)
WORKDIR /app
COPY composer.json composer.lock ./

# CAMBIO 1: Agrega --no-scripts
RUN composer install --no-dev --optimize-autoloader --no-scripts

# ... (Etapa de Producción)
FROM php:8.2-fpm-alpine

# CAMBIO 2: Agrega postgresql-dev
RUN apk add --no-cache \
    nginx \
    supervisor \
    libpq \
    postgresql-client \
    postgresql-dev \  
    git \
    build-base \
    libzip-dev \
    libpng-dev \
    jpeg-dev \
    && docker-php-ext-install pdo pdo_pgsql zip gd
# ... (Resto del Dockerfile)
