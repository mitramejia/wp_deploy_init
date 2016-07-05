#!/usr/bin/env bash

set -o errexit
# set -o xtrace
# set -o errtrace
set -o nounset

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

apt-get install zsh

# ------------------------------------------------
# Download and install oh_my_zsh
# ------------------------------------------------

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# ------------------------------------------------
# Download and install SCM_Breeze
# ------------------------------------------------

if hash git 2>/dev/null; then 
	prompt ${purple} "SCM_Breeze is already installed"
else
	prompt ${purple} "Installing SCM_Breeze..."
	git clone git://github.com/ndbroadbent/scm_breeze.git ~/.scm_breeze
	~/.scm_breeze/install.sh
	source ~/.zshrc   # or source ~/.zshrc
fi
