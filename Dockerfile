FROM php:7.4-fpm-alpine

ENV PHPREDIS_VERSION 5.3.1

RUN echo http://mirrors.aliyun.com/alpine/v3.10/main/ > /etc/apk/repositories && \
    echo http://mirrors.aliyun.com/alpine/v3.10/community/ >> /etc/apk/repositories
RUN apk update && apk upgrade

RUN set -eux; \
	apk add --no-cache bash; \
	apk add --no-cache gcc g++ make libffi-dev openssl-dev autoconf; \
	apk add --no-cache php7-pdo php7-pdo_mysql; \
	apk add --no-cache composer; \
	# composer
	composer self-update; \
	apk add --no-cache gd\
	    zlib-dev \
	    freetype \
	    freetype-dev \
	    libpng \
	    libpng-dev \
	    libjpeg-turbo \
	    libjpeg-turbo-dev \
	    ; \
	# gd
	docker-php-ext-configure gd \
	    --with-freetype=/usr/include/ \
	    --with-jpeg=/usr/include/; \
	docker-php-ext-install gd; \
	# redis
	curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz; \
	cd /tmp; \
	tar xfz redis.tar.gz; \
	mkdir -p /usr/src/php/ext; \
    mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis; \
	docker-php-ext-install redis pdo_mysql; \
    # swoole
    echo 'down swoole...'; \
    curl -L -o /tmp/swoole.tar.gz https://github.com/swoole/swoole-src/archive/v4.5.4.tar.gz; \
    cd /tmp; \
    tar zxvf swoole.tar.gz; \
    mv swoole-src* swoole-src; \
    cd swoole-src; \
    phpize; \
    ./configure \
        --enable-openssl \
        --enable-http2; \
    make && make install; \
    echo 'extension=swoole.so' >> /usr/local/etc/php/conf.d/swoole.ini; \
	#mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
	docker-php-source delete; \
	apk del g++; \
	rm -rf /tmp/*; \
	rm -rf /var/cache/apk/*; \
	rm -rf /tmp/pear ~/.pearrc;
