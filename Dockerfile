FROM php:7.4-fpm-alpine

ENV PHPREDIS_VERSION 5.3.1

RUN echo http://mirrors.aliyun.com/alpine/v3.10/main/ > /etc/apk/repositories && \
    echo http://mirrors.aliyun.com/alpine/v3.10/community/ >> /etc/apk/repositories
RUN apk update && apk upgrade

RUN set -eux; \
	apk add --no-cache bash; \
	apk add php7-pdo; \
	apk add php7-pdo_mysql; \
	apk add composer; \
	curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz; \
	cd /tmp; \
	tar xfz redis.tar.gz; \
	mkdir -p /usr/src/php/ext; \
    mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis; \
	docker-php-ext-install redis pdo_mysql; \
	rm -rf /tmp/*; \
	rm -rf /var/cache/apk/*; \
	mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
	composer self-update;