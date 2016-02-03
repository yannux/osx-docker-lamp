#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

# CONF APACHE
sed -i -e "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=staff/" /etc/apache2/envvars
sed -i -e "s/##ServerName/ServerName ${APACHE_VHOST_SERVERNAME}/" /etc/apache2/sites-available/default
sed -i -e "s/^#AddDefaultCharset UTF-8$/AddDefaultCharset UTF-8/" /etc/apache2/conf.d/charset

# CONF PHP
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/"
sed -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
## Quelques paramètres de conf qui ne me conviennent pas, pour une machine de développement / test (https://github.com/pmartin)
## https://github.com/pmartin/vm-dev-php/blob/master/scripts-install-vm/zz-install-php5.3.sh
sed -i -e 's/^short_open_tag = On$/short_open_tag = Off/' /etc/php5/apache2/php.ini
sed -i -e 's/^error_reporting = E_ALL & ~E_DEPRECATED$/error_reporting = E_ALL \& E_STRICT/' /etc/php5/apache2/php.ini
sed -i -e 's/^display_errors = Off$/display_errors = On/' /etc/php5/apache2/php.ini
sed -i -e 's/^track_errors = Off$/track_errors = On/' /etc/php5/apache2/php.ini
sed -i -e 's/^html_errors = Off$/html_errors = On/' /etc/php5/apache2/php.ini

if [ -n "$VAGRANT_OSX_MODE" ];then
    usermod -u $DOCKER_USER_ID www-data
    groupmod -g $(($DOCKER_USER_GID + 10000)) $(getent group $DOCKER_USER_GID | cut -d: -f1)
    groupmod -g ${DOCKER_USER_GID} staff
    chmod -R 770 /var/lib/mysql
    chmod -R 770 /var/run/mysqld
    chown -R www-data:staff /var/lib/mysql
    chown -R www-data:staff /var/run/mysqld
else
    # Tweaks to give Apache/PHP write permissions to the app
    chown -R www-data:staff /var/www
    chown -R www-data:staff /app
    chown -R www-data:staff /var/lib/mysql
    chown -R www-data:staff /var/run/mysqld
    chmod -R 770 /var/lib/mysql
    chmod -R 770 /var/run/mysqld
fi

sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
sed -i "s/user.*/user = www-data/" /etc/mysql/my.cnf

if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"
    /create_mysql_users.sh
else
    echo "=> Using an existing volume of MySQL"
fi

exec supervisord -n
