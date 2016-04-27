#yannux/lamp-basic

Linux Apache MySQL PHP

Dockerfile basé sur [osx-docker-lamp, a.k.a dgraziotin/lampp](https://registry.hub.docker.com/u/dgraziotin/lamp/) qui permet de [supporter l'écriture sur les volumes avec Boot2Docker sur Mac OS X](https://github.com/boot2docker/boot2docker/issues/581)

##Utilisation

###Créer un container basique

	docker run -t -i -p 80:80 -p 3306:3306 --name monapp yannux/lamp-basic

À l'adresse http://[boot2docker ip, e.g., 192.168.59.103] vous devriez voir : "Hello world!" et le phpinfo();


###Charger votre application PHP

Structure suggéré du projet sur votre machine

- _Mon_Projet_
  - app
  - mysql (optionnel)

Le dossier app doit contenir la racine de votre application PHP

Créer un container qui charge votre application en vous plaçant dans votre dossier _Mon_Projet_ :

	docker run -i -t -p "80:80" -p "3306:3306" -v ${PWD}/app:/app --name monapp yannux/lamp-basic


Pour avoir les donnés MySql dans un dossier local sur votre poste :

	docker run -i -t -p "80:80" -p "3306:3306" -v ${PWD}/mysql:/var/lib/mysql -v ${PWD}/app:/app --name monapp yannux/lamp-basic

Votre base de données MySQL sera persistante à chaque itéartion de l'image.


##Description de l'environment dans le container

### Programmes

Paquets installés : git, nano, wget

###Apache && /app

Apache est configuré pour servire les fichiers du dossier `/app`.

L'utilisateur Apache `www-data` a tous les droits sur le dossier `/app`.

Sur Mac OS X le support de l'écriture, lors de l'utilisation d'un volume,
fonctionne car l'utilisateur `www-data` est configuré avec le même
user id que celui employé par boot2docker.

Mod rewrite activé.

###PHP

Modules inclus : Mysql, Apc, Xdebug, Imagick, Pear

Xdebug est configuré avec le debugage à distance (conf/php/xdebug.ini)

###MySQL

MySQL fonctionne aussi avec l'utilisateur système `www-data`.
*Ce n'est pas un paramètrage correct pour un environment de production.*

En développement sur Mac OS X celà permet de gérer le droit d'écriture lorsqu'on monte un volume pour les données MySQL.

Pour gérer la base de données il suffit de se connecter avec l'utilisateur root et sans mot de passe
(* C'est un environment purement pour le développement *)

##Variables Environment

- PHP_UPLOAD_MAX_FILESIZE [10M]
- PHP_POST_MAX_SIZE [10M]
- APACHE_VHOST_SERVERNAME [localhost] : vide par défaut, permet de configuré le VirtualHost avec un Servername tel que monapp.dev au lieu d'utiliser l'ip docker pour accèder à l'application

Utilisez le flag `-e` pour spécifier les variables d'environment.

	docker run -i -t -p "80:80" -p "3306:3306" -v ${PWD}/app:/app -e APACHE_VHOST_SERVERNAME="monapp.dev" --name monapp yannux/lamp-basic

