# 1. Etapa de Construcción (Build Stage)
FROM composer:2 AS composer_install

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de configuración y composer
COPY composer.json composer.lock ./

# Instala las dependencias de PHP
RUN composer install --no-dev --optimize-autoloader

# 2. Etapa de Producción (Production Stage)
FROM php:8.2-fpm-alpine

# Instala dependencias del sistema y extensiones de PHP necesarias para Laravel
RUN apk add --no-cache \
    nginx \
    supervisor \
    libpq \
    postgresql-client \
    git \
    build-base \
    libzip-dev \
    libpng-dev \
    jpeg-dev \
    && docker-php-ext-install pdo pdo_pgsql zip gd

# Copia la instalación de Composer de la etapa de construcción
COPY --from=composer_install /app /var/www/html

# Establece el directorio de trabajo al directorio de la aplicación
WORKDIR /var/www/html

# Copia el resto del código de la aplicación
COPY . .

# Genera la clave de la aplicación y optimiza la configuración
RUN php artisan key:generate
RUN php artisan config:cache
RUN php artisan route:cache

# Configura los permisos de escritura para Laravel
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# Copia la configuración de Nginx (necesitas crear el archivo nginx.conf)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Define el comando de inicio usando Supervisor (para PHP-FPM y Nginx)
# Nota: La configuración de Supervisor (supervisord.conf) debe ser copiada también.
# Simplificando para Render, a veces es más fácil ejecutar solo PHP-FPM si se usa un proxy inverso.
# Pero para un Web Service simple, Nginx + PHP-FPM es común.

# Expone el puerto por defecto de Nginx o PHP-FPM (depende de tu setup)
EXPOSE 80

# Comando para ejecutar Nginx y PHP-FPM (esto requiere un script de inicio o Supervisor)
# Para simplificar y solo ejecutar PHP-FPM (si Render actúa como proxy al puerto 9000):
# CMD ["php-fpm"] 
# Si usas Nginx interno (opción más común):
# CMD ["nginx", "-g", "daemon off;"]