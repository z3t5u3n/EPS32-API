FROM php:8.3-apache

# 1. INSTALAR DEPENDENCIAS DE LINUX
# Se instala libpq-dev para la conexión a PostgreSQL.
RUN apt-get update && \
    apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libpq-dev \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. INSTALAR EXTENSIONES DE PHP
# Se instala pdo_pgsql para PostgreSQL.
RUN docker-php-ext-install pdo_pgsql zip gd

# Instala Composer globalmente
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia los archivos del proyecto a la carpeta de Apache
COPY . /var/www/html/

# Cambia el directorio de trabajo
WORKDIR /var/www/html

# 3. CONFIGURACIÓN Y OPTIMIZACIÓN DE LARAVEL (Fase de Build)
# Instala dependencias (sin dependencias de desarrollo)
RUN composer install --no-dev --optimize-autoloader

# Genera la clave de la aplicación y optimiza rutas/vistas
# Mantenemos esto para generar el APP_KEY si es necesario
RUN php artisan key:generate
# ELIMINAMOS 'config:cache' para que lea el DB_HOST de Render al iniciar
# ELIMINAMOS 'route:cache' para evitar conflictos, lo haremos en el Start Command

# Establece los permisos correctos (esenciales para Laravel)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 4. AJUSTE DEL SERVIDOR WEB (Apache)
RUN a2enmod rewrite
COPY .docker/000-default.conf /etc/apache2/sites-available/000-default.conf

# ELIMINAMOS la línea 'RUN php artisan config:cache' si estaba presente.