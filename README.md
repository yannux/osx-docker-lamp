osx-docker-lamp
=================

This is a fork of tutumcloud/tutum-docker-lamp, which is an

	Out-of-the-box LAMP Docker image (Apahce+PHP+MySQL+PhpMyAdmin) on steroids

osx-docker-lamp does what tutumcloud/tutum-docker-lamp, plus:

- It fixes OS X related write permission errors for Apache folder
- It lets you mount OS X folders with write support as volumes for
  - The website
  - The database
- It creates a default database and user with permissions to that database
- It provides phpMyAdmin at /phpmyadmin
- It is documented for less advanced users (like me)

Usage
-----

To create the image `youruser/docker-osx-lamp`, execute the following 
command from the `osx-docker-lamp` folder:

	docker build -t youruser/docker-osx-lamp .

You can now push your new image to the registry:

	docker push youruser/docker-osx-lamp


Running your LAMP docker image
------------------------------

If you start your newly image without supplying your code, e.g.,

	docker run -t -i -p 80:80 -p 3306:3306 --name osxlamp dgraziotin/docker-osx-lamp

At http://[boot2docker ip here, e.g., 192.168.59.103] you should see an 
"Hello world!" page.

At http://[boot2docker ip]/phpmyadmin you should see a running phpMyAdmin instance.

Loading your custom PHP application
-----------------------------------

In order to replace the "Hello World" application that comes bundled with this docker image,
create a folder containing 

- Your Web app in a subfolder called `app`
- A `Dockerfile` with the following contents:

	FROM youruser/docker-osx-lamp
	EXPOSE 80 3306
	CMD ["/run.sh"]

After that, build the new `Dockerfile`:

	docker build -t youruser/my-website .

And test it:

	docker run -d -p 80:80 -p 3306:3306 --name mywebsite youruser/my-website

Test your deployment:

	curl http://[boot2docker ip here, e.g., 192.168.59.103]


Environment description
-----------------------

The /app folder
_______________

Apache is configured to serve the files from the `/app` folder, which is a symbolic
link to `/var/www/html`. In osx-docker-lamp, the apache user `www-data` 
has full write permissions to the `app` folder.

Apache
______

Apache is pretty much standard in this image. It is configured to serve the Web app
at `app` as `/` and phpMyAdmin as `/phpmyadmin`. Mod rewrite is enabled.
Apache runs as user www-data and group staff. The write support works because the
user www-data is setup to have the same user id as the one employed by boot2docker (1000).

phpMyAdmin
__________

The latest version of phpMyAdmin is grabbed from sourceforge and installed in
the folder `/var/www/phpmyadmin`. PhpMyAdmin can be reached from 
http://[boot2docker ip]/phpmyadmin. Only the users `admin` and `user` can access
phpMyAdmin.

At your convenience, a not-so-random blowfish_secret is stored in phpMyAdmin 
configuration, which is at `/var/www/phpmyadmin/config.inc.php`

MySQL
-----

MySQL runs as user www-data, as well.

The three MySQL users
_____________________

The bundled MySQL server has three  users, that are `root`, `admin`, and `user`. 

The `root` account comes with an empty password, and it is for local connections
(e.g., using some code). The `root` user cannot remotely access the database 
(and the container).

However, the first time that you run your container, a new user `admin` 
with all root privileges  will be created in MySQL with a random password. 

To get the password, check the logs of the container by running:

	docker logs [name or id, e.g., mywebsite]

You will see an output like the following:

	========================================================================
	You can now connect to this MySQL Server using:

	    mysql -uadmin -p47nnf4FweaKu -h<host> -P<port>

	Please remember to change the above password as soon as possible!
	MySQL user 'root' has no password but only allows local connections
	========================================================================

In this case, `47nnf4FweaKu` is the password allocated to the `admin` user.

Finally, a user called `user` with password `password` is created for your convenience.
The `user` user has full privileges on a database called `db`, which is also created
for your convenience.

Environment variables
_____________________

- MYSQL_ADMIN_PASS="mypass" will use your given MySQL password for the `admin`
user instead of the random one.
- MYSQL_USER_NAME="daniel" will use your given MySQL username instead of `user`
- MYSQL_USER_DB="supercooldb" will use your given database name instead of `db`
- MYSQL_USER_PASS="supersecretpassword" will use your given password  instead of `password`


Set these variables using the `-e` flag when invoking the `docker` client.

	docker run -d -p 80:80 -p 3306:3306 -e MYSQL_ADMIN_PASS="mypass" --name mywebsite youruser/my-website
