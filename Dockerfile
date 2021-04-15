FROM php:alpine

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk --no-cache add \
        bash \
        libzip-dev \
        zip \
        curl \
        git \
        patch \
  && docker-php-ext-install zip

RUN curl https://raw.githubusercontent.com/saucal/wp-codesniffer-installer/master/install-standards.sh | sh

RUN curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

COPY entrypoint.sh /worker/entrypoint.sh
COPY rdjson-conv.php /worker/rdjson-conv.php
COPY count-fixable.php /worker/count-fixable.php

ENTRYPOINT ["bash", "/worker/entrypoint.sh"]
