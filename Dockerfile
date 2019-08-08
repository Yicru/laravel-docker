FROM php:7.3-fpm-alpine
MAINTAINER yicru

# install packages
RUN apk add --no-cache \
    bash \
    git \
    curl-dev \
    libxml2-dev \
    postgresql-dev \
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
    pdo_pgsql \
    pgsql \
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

# install dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# add user
RUN apk add sudo shadow \
    && groupadd -g 1000 yicru \
    && useradd -u 1000 -g 1000 yicru \
    && sed -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' \
    -i /etc/sudoers \
    && sed -e 's/^wheel:\(.*\)/wheel:\1,yicru/g' -i /etc/group \
    && mkdir /home/yicru && chown 1000:1000 -R /home/yicru \
    && mkdir /work && chown 1000:1000 -R /work

# supervisor nginx
RUN apk add --no-cache supervisor \
    && mkdir /run/supervisor \
    && apk add --no-cache nginx \
    && mkdir /run/nginx \
    && chown -R 1000:1000 /run/nginx \
    && chown -R 1000:1000 /var/lib/nginx

# basic auth
RUN apk add --no-cache apache2-utils

WORKDIR /work
USER yicru

ENTRYPOINT []
CMD php-fpm
