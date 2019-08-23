FROM php:7.3-fpm-alpine
MAINTAINER yicru

# install packages
RUN apk add --no-cache \
    bash \
    git \
    curl-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    zip \
    libzip-dev \
    unzip \
    gmp-dev

# install PHP extensions
RUN docker-php-source extract \
    && cp /usr/src/php/ext/openssl/config0.m4 /usr/src/php/ext/openssl/config.m4 \
    && docker-php-ext-configure gd --with-png-dir=/usr/include --with-jpeg-dir=/usr/include \
    && docker-php-ext-install pdo \
    pdo_mysql \
    mysqli \
    mbstring \
    curl \
    ctype \
    xml \
    json \
    tokenizer \
    openssl \
    gd \
    zip \
    gmp \
    bcmath \
    exif

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require laravel/installer \
    && composer global require hirak/prestissimo
ENV PATH=~/.composer/vendor/bin:$PATH

# supervisor nginx
RUN apk add --no-cache supervisor \
    && mkdir /run/supervisor \
    && apk add --no-cache nginx \
    && mkdir /run/nginx \
    && chown -R 1000:1000 /run/nginx \
    && chown -R 1000:1000 /var/lib/nginx

WORKDIR /work

ENTRYPOINT []
CMD php-fpm
