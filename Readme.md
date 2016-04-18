# Wordpress deployment script

![Digital Ocean](http://www.cloudsprawl.net/wp-content/uploads/2015/07/DigitalOcean-Logo-1.jpg)
![Digital Ocean](http://www.cloudadmins.org/wp-content/uploads/2016/02/DockerLogo.png)

###Prerrequisites###
1. Local Wordpress installation with **git repository** initialized on the `wp-content/` folder.
2. **SSH access** to a remote server.
3. **Docker** installed on your remote machine.

### What this script does? 

1. Creates an app folder to store your Wordpress installation
2. Pulls the following docker images:
	* [Wordpress](https://hub.docker.com/_/wordpress/)
	* [MariaDB](https://hub.docker.com/_/mariadb/)
	* [PhpMyAdmin](https://hub.docker.com/r/corbinu/docker-phpmyadmin/)
3. Starts docker containers (Wordpress, Mariadb and PhpMyAdmin)
4. Creates a [git post-recieve hook](http://krisjordan.com/essays/setting-up-push-to-deploy-with-git)