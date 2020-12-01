#!/bin/bash

# Hide "last login" line when starting a new terminal session
touch $HOME/.hushlogin

# ------------------------------------ Update & Upgrade ---------------------------------
apt clean && apt update -y && apt upgrade -y &&
    # ------------------------------------ Install Tools ------------------------------------
    apt install -yq --fix-missing \
        net-tools \
        network-manager-openvpn-gnome network-manager-pptp network-manager-pptp-gnome network-manager-vpnc network-manager-vpnc-gnome \
        network-manager-openconnect network-manager-openconnect-gnome \
        build-essential \
        software-properties-common \
        python3-dev \
        python3-pip \
        python3-setuptools \
        git \
        unrar \
        gcc \
        make \
        curl \
        htop \
        vim \
        tcptrack \
        lnav \
        jq \
        guake \
        smem \
        mysql-server

# ---------------------------------------- Install some tools ----------------------------------------
# LazyDocker (A simple terminal UI for both docker and docker-compose)
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# The Fuck is a magnificent app, that corrects errors in previous console commands.
pip3 install thefuck

# ------------------------------------ Install PHP and Extentions ------------------------------------
add-apt-repository -y ppa:ondrej/php

# It's recommended to install xdebug after other extensions. This way you don't need manual
#     config and package manager will create config files for cli and fpm.
apt update -y && \
apt install -yq --fix-missing php8.0-{common,cli,fpm,bcmath,curl,gd,intl,mbstring,readline,mysql,opcache,sqlite3,xml,zip} && \
apt install -yq --fix-missing php8.0-xdebug

# Enable FPM module on apache
a2enmod proxy_fcgi setenvif
a2enconf php8.0-fpm

# ------------------------------------ Install & config DNS ------------------------------------
apt install -y resolvconf &&

    # Stop systemd-resolved to avoid overwrite resolv.conf file
    systemctl stop systemd-resolved &&

    # Disable systemd-resolved
    systemctl disable systemd-resolved &&

    # Set "Google" DNS addresses
    echo nameserver 8.8.8.8 >/etc/resolvconf/resolv.conf.d/tail &&
    echo nameserver 4.2.2.4 >>/etc/resolvconf/resolv.conf.d/tail &&

    # Make DNS addresses permanent
    resolvconf -u
# ------------------------------------ Install Docker CE ---------------------------------------
# Install packages to allow apt to use a repository over HTTPS
apt install -y \
    apt-transport-https \
    ca-certificates \
    gnupg-agent

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&

    # Add Docker stable repository
    add-apt-repository -y \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" &&
    apt update -y &&
    apt install -y docker-ce docker-ce-cli containerd.io &&

    # Run docker without sudo
    usermod -aG docker $USER &&
    sudo setfacl -m user:$USER:rw /var/run/docker.sock &&

    # ------------------------------------ Install Docker-Compose ------------------------------------
    curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &&
    chmod +x /usr/local/bin/docker-compose &&

    # Install command completion
    curl -L https://raw.githubusercontent.com/docker/compose/1.23.2/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
# ------------------------------------ Install zsh ----------------------------------------------
echo 'Install oh-my-zsh'
echo '-----------------'
rm -rf $HOME/.oh-my-zsh
curl -L https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

# Install powerlevel9k theme
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
# ------------------------------------ Symlink zsh prefs ----------------------------------------
rm $HOME/.zshrc
ln -s $HOME/.dotfiles/shell/.zshrc $HOME/.zshrc

# Add global gitconfig & gitignore
ln -s $HOME/.dotfiles/config/.gitconfig $HOME/.gitconfig
ln -s $HOME/.dotfiles/config/.global-gitignore $HOME/.global-gitignore

# Symlink vim prefs
rm $HOME/.vimrc
ln -s $HOME/.dotfiles/shell/.vimrc $HOME/.vimrc
rm $HOME/.vim
ln -s $HOME/.dotfiles/shell/.vim $HOME/.vim

# Symlink php-cs-fixer rules
ln -s $HOME/.dotfiles/config/php-cs-fixer/.php_cs.dist $HOME/.custom/.php_cs.dist

# ------------------------------------ Install some packages ------------------------------------
echo 'Install Composer'
echo '----------------'
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

echo 'Install PHP CS Fixer'
echo '--------------------'
composer global require friendsofphp/php-cs-fixer

echo 'Install PHP Code Sniffer'
echo '------------------------'
composer global require "squizlabs/php_codesniffer=*"

echo 'Install PHP Mess Detector'
echo '-------------------------'
composer global require "phpmd/phpmd=@stable"

echo 'Install Blackfire'
echo '-----------------'
wget -q -O - https://packages.blackfire.io/gpg.key | apt-key add -
echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list
apt update
apt install blackfire-agent
/etc/init.d/blackfire-agent restart
apt install blackfire-php
# blackfire config --client-id= --client-token=

echo '++++++++++++++++++++++++++++++'
echo 'All done!'
echo '++++++++++++++++++++++++++++++'
