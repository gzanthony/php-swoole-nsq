FROM ubuntu:19.04
MAINTAINER Anthony "cngzwing@vip.163.com"
LABEL Author="LiBoWen"
LABEL Version="2019.11"
LABEL Descruption="PHP 7.2 swoole 开发环境"

ENV TIMEZONE Asia/Chongqing
ENV DEBIAN_FRONTEND noninteractive

# 调试地址，默认用苹果主机的地址，如果是 windows 修改 mac 为 win 即可
ENV XDEBUG_HOST docker.for.win.localhost
# 调试监听端口
ENV XDEBUG_PORT 9100
ENV XDEBUG_IDEKEY PHPSTORM

RUN echo $TIMEZONE > /etc/timezone \
    && mkdir /data

RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
    && apt-get clean \
    && apt-get update


RUN apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
    && dpkg-reconfigure -f $DEBIAN_FRONTEND tzdata \
    && apt-get install -y vim libevent-dev \
        php7.2 \
        php7.2-fpm \
        php7.2-dev \
        php7.2-mbstring \
        php7.2-gd \
        php7.2-json \
        php7.2-opcache \
        php7.2-xml \
        php7.2-zip \
        php7.2-curl \
        php7.2-bcmath \
        php7.2-cli \
        php7.2-intl \
        php7.2-mysql

RUN pecl install -o -f redis \
    && pecl install -o -f swoole \
    && pecl install nsq \ 
    && pecl install -o -f xdebug \
    && echo " " >> /etc/php/7.2/fpm/php.ini \
    && echo "[xdebug]" >> /etc/php/7.2/fpm/php.ini \
    && echo "zend_extension=xdebug.so" >> /etc/php/7.2/fpm/php.ini \
    && echo "xdebug.idekey = ${XDEBUG_IDEKEY}" >> /etc/php/7.2/fpm/php.ini \
    && echo "xdebug.remote_enable = 1" >> /etc/php/7.2/fpm/php.ini \
    && echo "xdebug.remote_handler = \"dbgp\"" >> /etc/php/7.2/fpm/php.ini \
    && echo "xdebug.remote_mode = \"req\"" >> /etc/php/7.2/fpm/php.ini \
    && echo "xdebug.remote_autostart = 1" >> /etc/php/7.2/fpm/php.ini \
    && echo "xdebug.remote_host = ${XDEBUG_HOST}" >> /etc/php/7.2/fpm/php.ini \
    && echo "xdebug.remote_port = ${XDEBUG_PORT}" >> /etc/php/7.2/fpm/php.ini \
    && echo "xdebug.remote_log = /data/xdebug-remote.log" >> /etc/php/7.2/fpm/php.ini

RUN apt-get install -y --no-install-recommends libmcrypt-dev \
	&& rm -r /var/lib/apt/lists/* \
    && pecl install mcrypt

RUN sed -i "s/^;date\.timezone.*$/date\.timezone = Asia\/Chongqing/g" /etc/php/7.2/cli/php.ini \
    && sed -i "s/^upload_max_filesize.*$/upload_max_filesize = 200M/g" /etc/php/7.2/cli/php.ini \
    && sed -i "s/^;date\.timezone.*$/date\.timezone = Asia\/Chongqing/g" /etc/php/7.2/fpm/php.ini \
    && sed -i "s/^upload_max_filesize.*$/upload_max_filesize = 200M/g" /etc/php/7.2/fpm/php.ini \
    && sed -i "s/^post_max_size.*$/post_max_size = 100M/g" /etc/php/7.2/fpm/php.ini \
    && sed -i "s/^pid.*$/pid = \/run\/php7.2-fpm.pid/g" /etc/php/7.2/fpm/php-fpm.conf \
    && sed -i 's/^listen =.*$/listen = 0.0.0.0:9000/g' /etc/php/7.2/fpm/pool.d/www.conf \
    && sed -i 's/^user =.*$/user = root/g' /etc/php/7.2/fpm/pool.d/www.conf \
    && sed -i 's/^group =.*$/group = root/g' /etc/php/7.2/fpm/pool.d/www.conf

RUN echo "extension=redis.so" > /etc/php/7.2/mods-available/redis.ini \
    && echo "extension=swoole.so" > /etc/php/7.2/mods-available/swoole.ini \
    && echo "extension=nsq.so" > /etc/php/7.2/mods-available/nsq.ini \
    && echo "extension=mcrypt.so" > /etc/php/7.2/mods-available/mcrypt.ini \
    && ln -s /etc/php/7.2/mods-available/redis.ini /etc/php/7.2/cli/conf.d/20-redis.ini \
    && ln -s /etc/php/7.2/mods-available/redis.ini /etc/php/7.2/fpm/conf.d/20-redis.ini \
    && ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/cli/conf.d/20-mcrypt.ini \
    && ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/fpm/conf.d/20-mcrypt.ini \
    && ln -s /etc/php/7.2/mods-available/swoole.ini /etc/php/7.2/cli/conf.d/30-swoole.ini \
    && ln -s /etc/php/7.2/mods-available/swoole.ini /etc/php/7.2/fpm/conf.d/30-swoole.ini \
    && ln -s /etc/php/7.2/mods-available/nsq.ini /etc/php/7.2/cli/conf.d/20-nsq.ini \
    && ln -s /etc/php/7.2/mods-available/nsq.ini /etc/php/7.2/fpm/conf.d/20-nsq.ini

RUN cd /usr/local/bin \
    && curl -o composer-setup.php -XGET https://getcomposer.org/installer \
    && php composer-setup.php \
    && rm -f composer-setup.php \
    && mv composer.phar composer

WORKDIR /data
VOLUME ["/data"]

EXPOSE 80
EXPOSE 8000
EXPOSE 9000
EXPOSE 9001