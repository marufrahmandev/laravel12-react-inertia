############################################
# Multi-stage production Dockerfile
# Laravel 12 + React (Inertia) + Vite
# Target: Render (Docker image deploy)
############################################

##########
# 1) Composer dependencies (PHP) builder
##########
FROM composer:2 AS vendor

WORKDIR /app

# Install PHP dependencies (no dev, no scripts to avoid running artisan in build)
COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --no-scripts

# Copy full app and re-run install to pick up any path‑based packages (still no scripts)
COPY . .
RUN composer install \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts


##########
# 2) Node/Vite asset builder
##########
FROM node:22-alpine AS frontend

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY vite.config.js postcss.config.js tailwind.config.js jsconfig.json ./
COPY resources ./resources

RUN npm run build


##########
# 3) Final runtime image (PHP-FPM + Nginx + Supervisor)
##########
FROM php:8.4-fpm-alpine AS production

WORKDIR /var/www/html

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=20000 \
    PHP_OPCACHE_MEMORY_CONSUMPTION=256 \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER=16

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    git \
    bash \
    icu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    ca-certificates

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        intl \
        zip \
        opcache

# Copy application code & dependencies from builder stages
COPY --from=vendor /app /var/www/html
COPY --from=frontend /app/public/build /var/www/html/public/build

# Copy Docker-specific config
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY .docker/php.ini /usr/local/etc/php/conf.d/app.ini
COPY .docker/start-container.sh /usr/local/bin/start-container

RUN chmod +x /usr/local/bin/start-container

# Ensure correct permissions for Laravel writable directories
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R ug+rwx storage bootstrap/cache

# Nginx will listen on 8080; match this with Render's PORT env var / service port
EXPOSE 8080

# Start script: caches config/routes/views at runtime, then runs Supervisor
CMD ["start-container"]


