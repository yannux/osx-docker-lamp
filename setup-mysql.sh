#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

echo "=> Autorisation de l'utilisateur root MySQL en remote."
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION"

echo "=> Fait!"

echo "========================================================================"
echo "Pour se connecter au serveur MySQL "
echo ""
echo "    mysql -uroot -h<host> -P<port>"
echo ""
echo "========================================================================"

mysqladmin -uroot shutdown
