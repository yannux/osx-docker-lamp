#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini

sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
sed -i "s/user.*/user = www-data/" /etc/mysql/my.cnf

if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mkdir /var/lib/mysql
    chown -R www-data:staff /var/lib/mysql
    chown -R www-data:staff /var/run/mysqld
    chmod -R 777 /var/lib/mysql
    chmod -R 777 /var/run/mysqld
    mysql_install_db > /dev/null 2>&1
    chown -R www-data:staff /var/lib/mysql
    chown -R www-data:staff /var/run/mysqld
    chmod -R 777 /var/lib/mysql
    chmod -R 777 /var/run/mysqld
    echo "=> Done!"  
    /create_mysql_users.sh
else
    echo "=> Using an existing volume of MySQL"
fi

chown -R www-data:staff /var/lib/mysql
chown -R www-data:staff /var/run/mysqld
chmod -R 777 /var/lib/mysql
chmod -R 777 /var/run/mysqld

exec supervisord -n
