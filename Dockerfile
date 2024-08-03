FROM node:10 as frontend
COPY ./Frontend /usr/src/Frontend
WORKDIR /usr/src/Frontend
RUN npm --registry https://registry.npmmirror.com install && \
    npm run build

FROM php:7.4-cli
COPY ./AoiAWD /usr/src/AoiAWD
WORKDIR /usr/src/AoiAWD
RUN pecl install -D 'enable-mongodb-developer-flags="no" enable-mongodb-coverage="no" with-mongodb-system-libs="no" with-mongodb-client-side-encryption="auto" with-mongodb-snappy="auto" with-mongodb-zlib="auto" with-mongodb-zstd="auto" with-mongodb-sasl="auto" with-mongodb-ssl="auto" enable-mongodb-crypto-system-profile="no" with-mongodb-utf8proc="bundled"' mongodb && \
    docker-php-ext-enable mongodb && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    echo "phar.readonly=Off" > "$PHP_INI_DIR/conf.d/phar.ini" && \
    rm -rf ./src/public/static/*
COPY --from=frontend /usr/src/Frontend/dist/* ./src/public/static/
RUN mv ./src/public/static/index.html ./src/public/index.html 
RUN php ./compile.php

ENTRYPOINT [ "php", "./aoiawd.phar" ]
