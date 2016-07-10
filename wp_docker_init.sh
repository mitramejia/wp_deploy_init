#!/usr/bin/env bash

set -o errexit
# set -o xtrace
# set -o errtrace
set -o nounset

#
# ============================================================================
# VARIABLES
# ============================================================================
#

# Set magic variables for current file and its directory.
# BASH_SOURCE[0] is used so we can display the current file even if it is sourced by a parent script.
# If you need the script that was executed, consider using $0 instead.

random_pass="$(openssl rand -base64 32)"
droplet_ip=$(wget http://ipinfo.io/ip -qO -);

__script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__app_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"/app
__wordpress_dir=${__app_dir}/wordpress
__file="${__script_dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"

# ------------------------------------------------
# Colors
# ------------------------------------------------

red='\033[0;31m'     
green='\033[1;32m'     
yellow='\033[1;33m'
blue='\033[1;34m'
purple='\033[1;35m'     
gray='\033[1;36m'         
white='\033[0;37m'
no_color='\033[0m'


#
# ============================================================================
# FUNCTIONS
# ============================================================================
#

# ------------------------------------------------
# Helper functions
# ------------------------------------------------

function prompt() {
    message="$2"
    color="$1"
    printf "$color$message\033[0m\n"
}


#
# =============================================================================
# BODY
# =============================================================================
#

# ------------------------------------------------
# Update package list
# ------------------------------------------------
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  apt-get update 
fi

# ------------------------------------------------
# Make sure the script is being ran as root
# ------------------------------------------------

if [[ $EUID -ne 0 ]]; then
   prompt ${purple} "This script must run as root"
   exit 1
fi


# ------------------------------------------------
# Download and install ruby
# ------------------------------------------------

if hash ruby 2>/dev/null; then 
	prompt ${purple} "Ruby is already installed"
else
	prompt ${purple} "Installing ruby..."
	apt-get install ruby
	gem install colorize
fi


# ------------------------------------------------
# Download and install python pip
# ------------------------------------------------

if hash pip 2>/dev/null; then 
	prompt ${purple} "Python Pip is already installed."
else
	prompt ${purple} "Installing Pyhton Pip..."
	apt-get -y install python-pip;
fi


# ------------------------------------------------
# Download and install docker compose
# ------------------------------------------------

if hash docker-compose 2>/dev/null; then 
	prompt ${purple} "Docker Compose is already installed."
else
	prompt ${purple} "Installing Docker Compose..."
	pip install docker-compose
fi


# ------------------------------------------------
# Create app directory
# ------------------------------------------------

mkdir ${__app_dir}
# Move dockerfiles to app directory
cp -r ./dockerfiles ${__app_dir}


# ------------------------------------------------
# Create docker-compose.yml
# ------------------------------------------------

echo "
version: '2'

services:

  wordpress:
    container_name: wordpress
    build:
      context: ./dockerfiles/wordpress
      dockerfile: Dockerfile
    links:
      - wordpress_db:mysql
    ports:
      - 8080:80
    volumes:
      - '~/app/wordpress:/var/www/html'
    environment:
      WORDPRESS_DB_PASSWORD: ${random_pass}
      WORDPRESS_DB_USER: root
    restart: always

  wordpress_db: 
    container_name: db
    build:
      context: ./dockerfiles/mysql  
      dockerfile: Dockerfile
    volumes:
      - '~/app/database:/var/lib/mysql'
    restart: always
    environment: 
      MYSQL_ROOT_PASSWORD: ${random_pass} 


  phpmyadmin:
    container_name: phpmyadmin
    image: phpmyadmin/phpmyadmin
    links:
      - wordpress_db:mysql
    ports:
      - 8181:80
    environment:
      MYSQL_USERNAME: root
      MYSQL_ROOT_PASSWORD: ${random_pass}

    restart: always
    " > ${__app_dir}/docker-compose.yml 


# ------------------------------------------------
# Start Docker containers
# ------------------------------------------------

prompt ${purple} "Starting docker containers..."
cd ${__app_dir}
docker-compose up -d


# ------------------------------------------------
# Configure git
# ------------------------------------------------

prompt ${purple} "Configuring git..."

# Delete the wp-contet/ folder created by the wordpress docker container
rm -rf $(find ${__wordpress_dir} -name "wp-content")

#Create a new wp-content/ folder and initialize a bare git repository 
mkdir -p ${__wordpress_dir}/wp-content 
cd ${__wordpress_dir}
mkdir -p production.git && cd production.git
git init --bare
 
# Copy post-receive script to its proper git hooks/ folder 
cp ${__script_dir}/post-receive ${__wordpress_dir}/production.git/hooks/

# Make the post-receive script executable
chmod +x ${__wordpress_dir}/production.git/hooks/post-receive


# ------------------------------------------------
# Display instructions deploy from local machine
# ------------------------------------------------


prompt ${blue} "If you havent set your local wp-content/ folder as a git repo run:"
prompt ${white} "git init or git flow init"

prompt ${blue} "Now run these commands to configure your local wp-content/ folder to deploy here:"

prompt ${white} "git remote add production ssh://${droplet_ip}/~/app/wordpress/wp-content/production.git"
prompt ${white} "git remote set-url production root@${droplet_ip}:~/app/wordpress/wp-content/production.git"
prompt ${white} "git checkout master"
prompt ${white} "git push origin master"
prompt ${green} "Done"





