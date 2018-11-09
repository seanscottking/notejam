FROM php:5

COPY ./laravel/notejam /app
WORKDIR /app

RUN apt-get update && \
  apt-get install -y git zip libmcrypt-dev && \
  docker-php-ext-install mcrypt mysqli pdo pdo_mysql && \
  curl -s https://getcomposer.org/installer | php && \
  php composer.phar install

CMD php artisan serve --host 0.0.0.0 --port 8000
