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

COPY entrypoint.sh /entrypoint.sh
COPY rdjson-conv.php /rdjson-conv.php
COPY count-fixable.php /count-fixable.php

ENTRYPOINT ["bash", "/entrypoint.sh"]
