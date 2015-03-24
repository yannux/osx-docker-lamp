FROM phusion/baseimage:latest
MAINTAINER Daniel Graziotin <daniel@ineed.coffee>

# based on tutumcloud/tutum-docker-lamp
# MAINTAINER Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>

# pre-configure phpMyAdmin with default user and password
RUN echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
RUN echo 'phpmyadmin phpmyadmin/app-password-confirm password password' | debconf-set-selections 
RUN echo 'phpmyadmin phpmyadmin/mysql/admin-pass password password' | debconf-set-selections
RUN echo 'phpmyadmin phpmyadmin/mysql/app-pass password password' | debconf-set-selections
RUN echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt zip unzip phpmyadmin && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Adding phpMyAdmin to the active sites
RUN echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf

# needed for phpMyAdmin
run php5enmod mcrypt

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD app/ /app

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u 1000 www-data
RUN usermod -G staff www-data
RUN chgrp -R www-data /app
RUN chown -R www-data /app

EXPOSE 80 3306
CMD ["/run.sh"]