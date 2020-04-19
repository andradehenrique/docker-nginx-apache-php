FROM php:7-apache

RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libzip-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install mysqli pdo pdo_mysql gd zip

RUN a2dismod mpm_event && \
    a2dismod mpm_worker && \
    a2enmod mpm_prefork && \
    a2enmod ssl && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod rewrite

COPY php.ini $PHP_INI_DIR/conf.d/

EXPOSE 80 443