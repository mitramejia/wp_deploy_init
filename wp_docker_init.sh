#!/usr/bin/env bash

set -o errexit
set -o xtrace
set -o nounset

#
# ====================================================================================
# VARIABLES
# ====================================================================================
#

random_pass="$(openssl rand -base64 32)"
app_dir=~/app
script_dir=~/wp_docker_init.sh
droplet_ip=$(wget http://ipinfo.io/ip -qO -);

# ------------------------------------------------
# Colors
# ------------------------------------------------

red='\033[0;31m'     
light_red='\033[1;31m'
green='\033[0;32m'     
light_green='\033[1;32m'
yellow='\033[1;33m'
light_blue='\033[1;34m'
purple='\033[0;35m'     
cyan='\033[1;36m'     
light_cyan='\033[1;36m'
light_gray='\033[0;37m'     
white='\033[1;37m'
no_color='\033[0m'



#
# ====================================================================================
# FUNCTIONS
# ====================================================================================
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
# ====================================================================================
# BODY
# ====================================================================================
#

# ------------------------------------------------
# Make sure the script is being ran as root
# ------------------------------------------------

if [[ $EUID -ne 0 ]]; then
   prompt $cyan "This script must be run as root"
   exit 1
fi

prompt $purple "Configuring git..."


# ------------------------------------------------
# Download and install ruby
# ------------------------------------------------

if hash ruby 2>/dev/null; then 
	prompt $cyan "Ruby is already installed."
else
	prompt $green "Configuring git..."
	apt-get install ruby
	gem install colorize
fi

# ------------------------------------------------
# Download and install git
# ------------------------------------------------
# 
if hash git 2>/dev/null; then 
	prompt $cyan "SCM_Breeze is already installed."
else
	prompt $green "Installing SCM_Breeze..."
	git clone git://github.com/ndbroadbent/scm_breeze.git ~/.scm_breeze
	~/.scm_breeze/install.sh
	source ~/.bashrc   # or source ~/.zshrc
fi


# ------------------------------------------------
# Download and install python pip
# ------------------------------------------------

# Check if pip is installed
if hash pip 2>/dev/null; then 
	prompt $cyan "Python Pip is already installed."
else
	prompt $green "Installing Pyhton Pip..."
	apt-get -y install python-pip;
fi

# ------------------------------------------------
# Download and install docker compose
# ------------------------------------------------

if hash docker-compose 2>/dev/null; then 
	prompt $cyan "Docker Compose is already installed."
else
	prompt $green "Installing Docker Compose..."
	pip install docker-compose
fi

# ------------------------------------------------
# Create app directory
# ------------------------------------------------

mkdir $app_dir && cd $app_dir

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
    " > $app_dir/docker-compose.yml 


# ------------------------------------------------
# Download and install docker images
# ------------------------------------------------
# 
prompt $green "Pulling docker images..."

docker pull ubuntu
docker pull mariadb
docker pull corbinu/docker-phpmyadmin	

# ------------------------------------------------
# Start Docker containers
# ------------------------------------------------
prompt $green "Starting docker containers..."
cd $app_dir
docker-compose up -d

# ------------------------------------------------
# Configure git
# ------------------------------------------------

prompt $green "Configuring git..."
rm -rf $(find ~/ -name "wp-content")
mkdir -p $app_dir/wp-content  && cd $app_dir/wp-content
mkdir production.git && cd production.git
git init --bare
cp $script_dir/post-receive $app_dir/wp-content/production.git/hooks/
chmod -x post-receive

# ------------------------------------------------
# Display instructions deploy from local machine
# ------------------------------------------------

prompt $light_blue "Now go to your repo and run these commands to setup your local repo to deploy here"
prompt $white "git remote add production ssh://${droplet_ip}}/~/app/wp-content/production.git"
prompt $white "git checkout master"
prompt $white "git push origin master"
prompt $green "Done"





