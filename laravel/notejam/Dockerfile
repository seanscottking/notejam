FROM php:5

COPY . /app
WORKDIR /app

RUN apt-get update && \
  apt-get install -y git zip libmcrypt-dev && \
  docker-php-ext-install mcrypt && \
  curl -s https://getcomposer.org/installer | php && \
  php composer.phar install && \
  touch app/database/notejam.db && \
  php artisan -vvv migrate --force

CMD php artisan serve --host 0.0.0.0 --port 8000
