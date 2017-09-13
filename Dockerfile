FROM alpine:3.6

ENV NGINX_VERSION 1.12.1
ENV PHP_VERSION 7.1.9

WORKDIR /root

# Install runtime dependencies.
RUN apk add --no-cache \
# NGINX runtime dependencies.
    pcre \
    zlib \
    openssl \
# PHP runtime dependencies.
    pcre \
    zlib \
    openssl \
    libcurl \
    libedit \
    libxml2 \
    libjpeg-turbo \
    libpng \
    libzip

# Build stuff.
RUN apk add --no-cache --virtual .build-deps \
    curl \
    build-base \
# NGINX build dependencies.
    pcre-dev \
    zlib-dev \
    openssl-dev \
# PHP build dependencies.
    autoconf \
    pcre-dev \
    curl-dev \
    libedit-dev \
    libxml2-dev \
    openssl-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
# Build NGINX.
  && curl -fL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar -xz \
  && cd nginx-$NGINX_VERSION \
  && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-http_ssl_module \
  && make \
  && make install \
  && cd .. \
  && rm -rf nginx-$NGINX_VERSION \
# Build PHP.
  && curl -fL https://php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror | tar -xj \
  && cd php-$PHP_VERSION \
  && ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --with-config-file-path=/etc/php \
    --with-config-file-scan-dir=/etc/php/conf.d \
    --disable-cgi \
    --enable-phpdbg=no \
    --enable-fpm \
    --enable-opcache \
    --enable-mbstring \
    --with-mysqli \
    --with-pdo-mysql \
    --enable-exif \
    --with-pcre-regex=/usr \
    --with-zlib \
    --with-openssl \
    --with-curl \
    --with-libedit \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --enable-zip \
  && make \
  && make install \
  && cd .. \
  && rm -rf php-$PHP_VERSION \
# Clean up.
  && apk del .build-deps

RUN apk add --no-cache \
    vim \
    curl \
    supervisor \
# Drush runtime dependencies.
    mysql-client \
# CircleCI dependencies.
    git \
    openssh-client \
    tar \
    gzip \
    ca-certificates

RUN curl -fL https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

RUN adduser -D drupal

RUN su drupal -c 'composer global require drush/drush'

COPY root/etc/supervisord.conf /etc/

RUN mkdir -p /var/cache/nginx \
  && mkdir -p /var/log/nginx \
  && chown drupal:drupal /var/cache/nginx /var/log/nginx \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log
COPY root/etc/nginx/nginx.conf /etc/nginx/

COPY root/etc/php/conf.d/*.ini /etc/php/conf.d/
COPY root/etc/php-fpm.conf /etc/

RUN mkdir -p /etc/drush
COPY root/etc/drush/drushrc.php /etc/drush/

RUN mkdir -p /var/drupal/www
COPY root/var/drupal/www/index.php /var/drupal/www/
RUN chown -R drupal:drupal /var/drupal

EXPOSE 8080
USER drupal
WORKDIR /var/drupal
ENV PATH="/home/drupal/.composer/vendor/bin:${PATH}"
CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
