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
    libsqlite3-dev \
    python3 \
 && docker-php-ext-install pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd opcache \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Xdebug and configure it
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log=/var/www/html/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

EXPOSE 9001

# Enable Apache mod_rewrite for clean URLs
RUN a2enmod rewrite

# Clone the specific GitHub repository
RUN rm -rf /var/www/html/* && git clone https://github.com/mattseabrook/alttp_vt_randomizer.git /var/www/html/

# Set the working directory to the application's directory
WORKDIR /var/www/html

# Install PHP dependencies with Composer
RUN composer install
