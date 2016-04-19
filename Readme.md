# Wordpress deployment script

![Docker](http://www.cloudadmins.org/wp-content/uploads/2016/02/DockerLogo.png)

###Prerrequisites###
1. Local Wordpress installation with a **git repository** initialized in your `wp-content/` folder.
2. **SSH access** to your remote server.
3. **Docker** installed on your remote server.

### What this script does? 

1. Creates an app folder to store your Wordpress installation
2. Pulls the following docker images:
	* [Wordpress](https://hub.docker.com/_/wordpress/)
	* [MariaDB](https://hub.docker.com/_/mariadb/)
	* [PhpMyAdmin](https://hub.docker.com/r/corbinu/docker-phpmyadmin/)
3. Configures and starts required docker containers vía `docker-compose`
4. Creates a [git post-recieve hook](http://krisjordan.com/essays/setting-up-push-to-deploy-with-git)
5. Gives you instructions to setup your local machine 