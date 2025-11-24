#!/usr/bin/env sh
set -e

cd /var/www/html

echo "Running Laravel optimizations..."

php artisan config:cache --no-ansi --force || echo "config:cache failed, continuing..."
php artisan route:cache --no-ansi --force || echo "route:cache failed, continuing..."
php artisan view:cache --no-ansi --force || echo "view:cache failed, continuing..."

echo "Starting Supervisor (php-fpm + nginx)..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf


