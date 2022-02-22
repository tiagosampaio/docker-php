FROM php:7.3.33-fpm-buster

ARG GOSU_VERSION=1.11


# ENVIRONMENT VARIABLES ------------------------------------------------------------------------------------------------

ENV LS_OPTIONS "--color=auto"


# BASE INSTALLATION ----------------------------------------------------------------------------------------------------

## Install base dependencies
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
  apt-utils \
  sendmail-bin \
  sendmail \
  sudo \
  wget \
  unzip \
  && rm -rf /var/lib/apt/lists/*

## Install Tools
RUN apt update && apt install -y --no-install-recommends \
  git \
  lsof \
  vim \
  procps \
  watch \
  && rm -rf /var/lib/apt/lists/*

## Install PHP dependencies (required to configure the GD library)
RUN apt update && apt install -y --no-install-recommends \
  ## required to configure the GD library
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  zlib1g-dev \
  libwebp-dev \
  ## required to configure the LDAP
  libldb-dev \
  libldap2-dev \
  && rm -rf /var/lib/apt/lists/*

## Install required PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && install-php-extensions \
  bcmath \
  bz2 \
  calendar \
  exif \
  gd \
  gettext \
  gmp \
  igbinary \
  imagick \
  intl \
  ldap \
  mailparse \
  msgpack \
  mysqli \
  oauth \
  opcache \
  pcntl \
  pcov \
  pdo_mysql \
  pspell \
  raphf \
  redis \
  shmop \
  soap \
  sockets \
  sysvmsg \
  sysvsem \
  sysvshm \
  tidy \
  uuid \
  # Install the most recent xdebug 3.0.x version (for example 3.0.4)
  xdebug-^3.1 \
  xsl \
  yaml \
  zip \
  # Not available in PHP 8.0
  gnupg \
  propro \
  ssh2 \
  xmlrpc \
  sourceguardian \
  apcu \
  pgsql \
  oci8

## Configure the GD library
RUN docker-php-ext-configure \
  gd --with-gd \
     --with-freetype-dir=/usr/include/ \
     --with-jpeg-dir=/usr/include/ \
     --with-webp-dir=/usr/include/
RUN docker-php-ext-configure \
  ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-configure \
  opcache --enable-opcache


## Install Composer (version one and two)
RUN curl -o /usr/local/bin/composer -O https://getcomposer.org/composer-2.phar && \
    curl -o /usr/local/bin/composer1 -O https://getcomposer.org/composer-1.phar && \
    ln -s /usr/local/bin/composer /usr/local/bin/composer2 && \
    chmod +x /usr/local/bin/composer*


# BASE CONFIGURATION ---------------------------------------------------------------------------------------------------

## Disable XDebug by default
RUN sed -i -e 's/^zend_extension/\;zend_extension/g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


#-----------------------------------------------------------------------------------------------------------------------
