FROM php:7-alpine

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk --no-cache add \
        bash \
        libzip-dev \
        zip \
        curl \
        git \
        patch \
        nodejs \
        npm \
        jq \
  && docker-php-ext-install zip

RUN curl https://raw.githubusercontent.com/saucal/wp-codesniffer-installer/master/install-standards.sh | sh

RUN curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN mkdir -p /worker

RUN cd /worker && composer require ptlis/diff-parser

COPY worker/linter/npm-install/package.json /worker/linter/npm-install/package.json
RUN cd /worker/linter/npm-install && npm install --save --package-lock-only --no-progress @wordpress/scripts && npm cache clean --force
RUN cp -f /worker/linter/npm-install/package.json /tmp/worker-package.json

COPY entrypoint.sh /entrypoint.sh
COPY worker /worker

RUN cp -f /tmp/worker-package.json /worker/linter/npm-install/package.json

RUN echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

ENTRYPOINT ["bash", "/entrypoint.sh"]
