# lamp-basic
FROM debian:squeeze
MAINTAINER Yann Nave <ynave@onbebop.net>

ENV DOCKER_USER_ID 501
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql && \
    groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1) && \
    groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install supervisor wget git nano apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-pear php-apc php5-mcrypt zip unzip php5-imagick php5-xdebug


# # APACHE & PHP
ADD start-apache2.sh /start-apache2.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD conf/apache/apache_default /etc/apache2/sites-available/default

RUN a2enmod rewrite & \
    rm /etc/apache2/sites-enabled/000-default & \
    a2ensite default

ADD conf/php/xdebug.ini /etc/php5/apache2/conf.d/xdebug.ini

# # MYSQL
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD start-mysqld.sh /start-mysqld.sh
ADD setup-mysql.sh /setup-mysql.sh
RUN rm -rf /var/lib/mysql


# Configure /app folder with sample app
RUN mkdir -p /app
ADD app/ /app


# ALL & SYSTE%
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# ENV
ENV APACHE_VHOST_SERVERNAME localhost
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# VOLUMES
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/app" ]

EXPOSE 80 3306

CMD ["/run.sh"]