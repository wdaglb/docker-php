FROM php:7.3-fpm-alpine

ENV PHPREDIS_VERSION 5.3.1
ENV SWOOLE_VERSION 4.8.12
#ENV PS1 [\u@\h \W]\$

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
#RUN echo http://mirrors.aliyun.com/alpine/v3.10/main/ > /etc/apk/repositories && \
#    echo http://mirrors.aliyun.com/alpine/v3.10/community/ >> /etc/apk/repositories
RUN apk update && apk upgrade

RUN set -eux; \
	#apk add --no-cache bash bash-doc bash-completion; \
	#apk add --no-cache bash; \
	apk add --no-cache gcc g++ make libffi-dev openssl-dev autoconf; \
	apk add --no-cache php7-pdo php7-pdo_mysql git; \
	#echo "export PS1='[\u@\h \W]\$'" > ~/.bash_profile; \
	#source ~/.bash_profile; \
	# apk add --no-cache composer; \
	curl -L -o /usr/local/bin/composer https://mirrors.aliyun.com/composer/composer.phar; \
	chmod a+x /usr/local/bin/composer; \
	composer self-update --2; \
	apk add --no-cache gd\
	    zlib-dev \
	    freetype \
	    freetype-dev \
	    libpng \
	    libpng-dev \
	    libjpeg-turbo \
	    libjpeg-turbo-dev \
		libzip-dev \
	    ; \
	# gd
	docker-php-ext-configure gd \
	    --with-freetype-dir=/usr/include/ \
	    --with-jpeg-dir=/usr/include/; \
	docker-php-ext-install gd bcmath; \
	# redis
	curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz; \
	cd /tmp; \
	tar xfz redis.tar.gz; \
	mkdir -p /usr/src/php/ext; \
    mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis; \
	docker-php-ext-install redis pdo_mysql zip; \
    # swoole
    echo 'down swoole...'; \
    curl -L -o /tmp/swoole.tar.gz https://github.com/swoole/swoole-src/archive/v$SWOOLE_VERSION.tar.gz; \
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

WORKDIR /www
