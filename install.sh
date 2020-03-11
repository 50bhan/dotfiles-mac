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
    unrar \
    gcc \
    make \
    curl \
    tilix \
    htop \
    vim \
    tcptrack \
    lnav \
    geoip-bin \
    mysql-server &&
# ------------------------------------ Install & config DNS ------------------------------------
apt install -y resolvconf &&
systemctl stop systemd-resolved && # Stop systemd-resolved to avoid overwrite resolv.conf file
systemctl disable systemd-resolved && # Disable systemd-resolved
echo nameserver 8.8.8.8 > /etc/resolvconf/resolv.conf.d/tail && # Set "Google" DNS addresses
echo nameserver 4.2.2.4 >> /etc/resolvconf/resolv.conf.d/tail && # Set "Google" DNS addresses
resolvconf -u # Make DNS addresses permanent
# ------------------------------------ Install Docker CE ---------------------------------------
# Install packages to allow apt to use a repository over HTTPS
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common &&

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
ln -s $HOME/.dotfiles/shell/.global-gitignore $HOME/.global-gitignore

# Symlink vim prefs
rm $HOME/.vimrc
ln -s $HOME/.dotfiles/shell/.vimrc $HOME/.vimrc
rm $HOME/.vim
ln -s $HOME/.dotfiles/shell/.vim $HOME/.vim

echo 'Install composer'
echo '----------------'
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

echo '++++++++++++++++++++++++++++++'
echo 'All done!'
echo '++++++++++++++++++++++++++++++'
