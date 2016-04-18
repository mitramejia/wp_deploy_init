#!/usr/bin/env bash

set -o errexit
set -o xtrace
set -o errtrace
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
___app_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ./ && pwd)"/app
__file="${__script_dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"


# ------------------------------------------------
# Colors
# ------------------------------------------------

red='\033[0;31m'     
green='\033[1;32m'     
yellow='\033[1;33m'
blue='\033[1;34m'
purple='\033[0;35m'     
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
# Make sure the script is being ran as root
# ------------------------------------------------

if [[ $EUID -ne 0 ]]; then
   prompt ${purple} "This script must be run as root"
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
# Download and install git
# ------------------------------------------------
# 
if hash git 2>/dev/null; then 
	prompt ${purple} "SCM_Breeze is already installed"
else
	prompt ${purple} "Installing SCM_Breeze..."
	git clone git://github.com/ndbroadbent/scm_breeze.git ~/.scm_breeze
	~/.scm_breeze/install.sh
	source ~/.bashrc   # or source ~/.zshrc
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

mkdir ${___app_dir} && cd ${___app_dir}


# ------------------------------------------------
# Create docker-compose.yml
# ------------------------------------------------

echo "
wordpress:
  image: wordpress
  links:
    - wordpress_db:mysql
  ports:
    - 80:80
  volumes:
    - '~/app:/var/www/html'
wordpress_db: 
  image: mariadb
  environment:
    MYSQL_ROOT_PASSWORD: ${random_pass}
phpmyadmin:
  image: corbinu/docker-phpmyadmin
  links:
    - wordpress_db:mysql
  ports:
    - 8181:80
  environment:
    MYSQL_USERNAME: root
    MYSQL_ROOT_PASSWORD: ${random_pass}
    " > ${___app_dir}/docker-compose.yml 


# ------------------------------------------------
# Download and install docker images
# ------------------------------------------------ 

prompt ${purple} "Pulling docker images..."

docker pull ubuntu
docker pull mariadb
docker pull corbinu/docker-phpmyadmin	


# ------------------------------------------------
# Start Docker containers
# ------------------------------------------------

prompt ${purple} "Starting docker containers..."
cd $app_dir
docker-compose up -d


# ------------------------------------------------
# Configure git
# ------------------------------------------------

prompt ${purple} "Configuring git..."
rm -rf $(find ${___app_dir} -name "wp-content")
mkdir -p ${___app_dir}/wp-content  && cd ${___app_dir}/wp-content
mkdir production.git && cd production.git
git init --bare
cp ${__script_dir}/post-receive ${___app_dir}/wp-content/production.git/hooks/
chmod -x post-receive


# ------------------------------------------------
# Display instructions deploy from local machine
# ------------------------------------------------

prompt ${purple} "Now go to your repo and run these commands to setup your local repo to deploy here"
prompt ${white} "git remote add production ssh://${droplet_ip}}/~/app/wp-content/production.git"
prompt ${white} "git checkout master"
prompt ${white} "git push origin master"
prompt ${green} "Done"





