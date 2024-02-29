# Use an official PHP 8.1 runtime as a parent image with Apache
FROM php:8.1-apache

# Change Apache Listen port to 9000
RUN sed -i '/Listen 80/c\Listen 9000' /etc/apache2/ports.conf
EXPOSE 9000

# Install system dependencies, PHP extensions required by Laravel and the randomizer project, Composer, and SQLite
RUN apt-get update && apt-get install -y \
    git \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    vim \
    npm \
    sqlite3 \
    python3 &&
    docker-php-ext-install pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd opcache &&
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Xdebug and configure it
RUN pecl install xdebug &&
    docker-php-ext-enable xdebug &&
    echo "xdebug.mode=debug" >>/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&
    echo "xdebug.start_with_request=yes" >>/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&
    echo "xdebug.client_host=host.docker.internal" >>/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&
    echo "xdebug.client_port=9001" >>/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&
    echo "xdebug.log=/var/www/html/xdebug.log" >>/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
EXPOSE 9001

# Enable Apache mod_rewrite for clean URLs
RUN a2enmod rewrite

# Clone the specific GitHub repository
RUN rm -rf /var/www/html/* &&
    git clone https://github.com/mattseabrook/alttp_vt_randomizer.git /var/www/html/

# Set the working directory to the application's directory
WORKDIR /var/www/html

# Install PHP dependencies with Composer
RUN composer install

# Install NPM dependencies and build assets
RUN npm install && npm run production

# Copy the .env.example file to .env and setup the application
RUN cp .env.example .env &&
    sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/g' .env &&
    sed -i 's/DB_DATABASE=homestead/DB_DATABASE=\/var\/www\/html\/database\/database.sqlite/g' .env &&
    touch database/database.sqlite

# Generate key and cache configuration
RUN php artisan key:generate &&
    php artisan config:cache

# Run database migrations
RUN php artisan migrate

# Permissions adjustment, to ensure that the web server can access the necessary files
RUN chown -R www-data:www-data /var/www/html &&
    find /var/www/html -type d -exec chmod 755 {} \; &&
    find /var/www/html -type f -exec chmod 644 {} \;

# When the container starts, serve the application via Apache in the foreground
CMD ["apache2-foreground"]
