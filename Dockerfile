# Use PHP 7.2
FROM php:7.2-fpm
RUN docker-php-ext-install pdo_mysql
# Set working directory
WORKDIR /var/www/perpus

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        git \
        unzip

# Install or update Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && composer self-update

# Clear Composer cache
RUN composer clear-cache

# Update dependencies
#RUN composer update --no-scripts --no-interaction --prefer-dist

# Copy composer.json and composer.lock to optimize Docker build
COPY composer.json composer.lock .

# Install application dependencies
#RUN composer install --no-scripts --no-interaction

# Copy the application files to the container
COPY . .

# Run "composer update" in the directory /var/www/perpus
RUN composer update

RUN composer install

# Copy .env.example to .env
RUN cp .env.example .env

# Run "php artisan key:generate" to generate APP_KEY in .env
RUN php artisan key:generate

# Set up database configuration in ".env"
# Replace the values below with your actual database configuration
ENV DB_CONNECTION=mysql
ENV DB_HOST=127.0.0.1
ENV DB_PORT=3306
ENV DB_DATABASE=perpusku_gc
ENV DB_USERNAME=root
ENV DB_PASSWORD=root

RUN php artisan serve --host=0.0.0.0 --port=8000
# Run "php artisan migrate" and "php artisan db:seed"
#COPY docker-entrypoint.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/docker-entrypoint.sh
#ENTRYPOINT ["docker-entrypoint.sh"]

# Expose port 8000
EXPOSE 8000
CMD ["php","artisan","serve","--host=0.0.0.0","--port=8000"]

