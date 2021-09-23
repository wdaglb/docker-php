FROM php:5.6-fpm
COPY ./php.ini /usr/local/etc/php/php.ini
ENV PHPREDIS_VERSION 4.2.0
ENV BUILD_DIR /build

RUN usermod -u 1000 www-data \
    && groupmod -g 1000 www-data

RUN docker-php-source extract \
    && apt-get update \
    && apt-get install -y imagemagick  \
    && apt-get install -y libmagickwand-dev libmagickcore-dev \
    && apt-get install -y zip unzip libpng-dev libfreetype6-dev libjpeg62-turbo-dev openssh-server \
    # git
    && apt-get install -y openssl libssl-dev zlib1g-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip \
    && mkdir $BUILD_DIR \
    && cd $BUILD_DIR \
    && curl -L -o $BUILD_DIR/git.tar.gz https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz \
    && tar xvf git.tar.gz \
    && rm -rf git.tar.gz \
    && cd git-2.9.5 \
    && make prefix=/usr/local all \
    && make prefix=/usr/local install \

    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo pdo_mysql mysqli iconv zip \
    && docker-php-ext-install gd \
    && echo 'mysql complete!' \
	
    && cd $BUILD_DIR \
    && curl -L -o $BUILD_DIR/imagick.tgz https://pecl.php.net/get/imagick-3.4.3.tgz \
    && tar zxvf imagick.tgz \
    && cd imagick-3.4.3 \
    && phpize \
    && ./configure \
    && make && make install \
    && echo 'extension=imagick.so' >> /usr/local/etc/php/conf.d/docker-php-ext-imagick.ini \
	
	
    # reids
    && cd $BUILD_DIR \
    && curl -L -o $BUILD_DIR/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz redis.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis \
	
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://packagist.laravel-china.org \
    && echo 'composer complete!' \
    && rm -rf $BUILD_DIR \
    && docker-php-source delete

#USER 1000
WORKDIR /www
