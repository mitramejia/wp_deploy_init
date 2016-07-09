#!/usr/bin/env bash

set -o errexit
# set -o xtrace
# set -o errtrace
set -o nounset


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
# Make sure the script is being ran as root
# ------------------------------------------------

if [[ $EUID -ne 0 ]]; then
   prompt ${purple} "This script must run as root"
   exit 1
fi


# ------------------------------------------------
# Download and install zsh
# ------------------------------------------------

apt-get update
apt-get install zsh

# ------------------------------------------------
# Download and install oh_my_zsh
# ------------------------------------------------

if hash git 2>/dev/null; then 
	prompt ${purple} "OH My ZSH is already installed"
else
	prompt ${purple} "Installing OH My ZSH..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	source ~/.zshrc   # or source ~/.zshrc
fi


# ------------------------------------------------
# Download and install SCM_Breeze
# ------------------------------------------------

if hash gs 2>/dev/null; then 
	prompt ${purple} "SCM_Breeze is already installed"
else
	prompt ${purple} "Installing SCM_Breeze..."
	git clone git://github.com/ndbroadbent/scm_breeze.git ~/.scm_breeze
	~/.scm_breeze/install.sh
	source ~/.zshrc   # or source ~/.zshrc
fi

prompt ${green} "Done"
