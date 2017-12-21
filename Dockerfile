# Based on buildpack-deps:jessie (as of Dec 2017).
FROM node:8

ENV NGINX_GPGKEY 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
ENV SURY_PHP_GPGKEY DF3D585DB8F0EB658690A554AC0E47584A7A714D

RUN apt-get update \
  && apt-get install -y lsb-release ca-certificates apt-transport-https \
  && apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys $NGINX_GPGKEY $SURY_PHP_GPGKEY \
  && echo deb http://nginx.org/packages/debian/ $(lsb_release -sc) nginx >> /etc/apt/sources.list \
  && echo deb https://packages.sury.org/php/ $(lsb_release -sc) main >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install --no-install-suggests --no-install-recommends -y \
    # Human dependencies.
    less \
    curl \
    vim \
    # Drush dependencies.
    mysql-client \
    # CircleCI dependencies.
    git \
    openssh-client \
    tar \ 
    gzip \
    ca-certificates \
    # Cypress dependencies.
    libgtk2.0-0 \
    libnotify-dev \
    libgconf-2-4 \
    libnss3 \
    libxss1 \
    libasound2 \
    xvfb \
    libxtst6 \
    # Web server packages.
    supervisor \
    nginx \
    php7.1-fpm \
    php7.1-cli \
    php7.1-curl \
    php7.1-json \
    php7.1-gd \
    php7.1-mbstring \
    php7.1-mysql \
    php7.1-opcache \
    php7.1-readline \
    php7.1-sqlite3 \
    php7.1-xml \
    php7.1-zip \
    # TODO: Install Xdebug?
  && rm -rf /var/lib/apt/lists/* \
  && apt-get purge -y --auto-remove

# TODO: Figure out why Debian's BusyBox does not include sendmail.
# TODO: Verify integrity of this download.
RUN curl https://www.busybox.net/downloads/binaries/1.26.2-defconfig-multiarch/busybox-x86_64 > /usr/local/bin/busybox \
  && chmod a+x /usr/local/bin/busybox \
  && ln -s /usr/local/bin/busybox /usr/local/bin/sendmail

RUN curl -fL https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

RUN adduser --disabled-password --gecos '' drupal

RUN su drupal -c 'composer global require \
    drush/drush \
    pantheon-systems/terminus'

COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log
COPY nginx.conf /etc/nginx/nginx.conf

COPY php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf
COPY php.drupal.ini /etc/php/7.1/mods-available/drupal.ini
RUN ln -s /etc/php/7.1/mods-available/drupal.ini /etc/php/7.1/cli/conf.d/80-drupal.ini \
  && ln -s /etc/php/7.1/mods-available/drupal.ini /etc/php/7.1/fpm/conf.d/80-drupal.ini

RUN mkdir -p /projects/drupal/web
COPY index.php /projects/drupal/web/index.php

RUN mkdir -p /home/drupal/.drush
COPY drushrc.php /home/drupal/.drush/

COPY dotmy.cnf /home/drupal/.my.cnf

RUN chmod a+w /var/run /var/cache/nginx /var/log/nginx
RUN chown -R drupal:drupal /projects /home/drupal

USER drupal
ENV PATH "/home/drupal/.composer/vendor/bin:${PATH}"
ENV SIMPLETEST_BASE_URL http://localhost:8080
ENV CYPRESS_BASE_URL http://localhost:8080
WORKDIR /projects

EXPOSE 8080
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
