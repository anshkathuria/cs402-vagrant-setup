#!/bin/bash

# Check if brew is installed
which -s brew
if [[ $? != 0 ]] ; then
   # Install Homebrew
   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
   brew update
fi

# Check if XQuartz is installed
which -s xquartz
if [[ $? != 0 ]] ; then
   # Install XQuartz
   brew cask install xquartz
fi

# Check if virtualbox is installed
which -s virtualbox
if [[ $? != 0 ]] ; then
   # Install Virual box
   brew cask install virtualbox
fi

# Check if vagrant is installed
which -s vagrant
if [[ $? != 0 ]] ; then
   # Install vagrant
   brew cask install vagrant
fi

read -p "Where do you want to install ubuntu vagrantbox? [~/vagrant16]: " SITEPOINT_DIR 
SITEPOINT_DIR=${SITEPOINT_DIR:-~/vagrant161}
rm -rf $SITEPOINT_DIR ||:
mkdir -p $SITEPOINT_DIR
mkdir -p $SITEPOINT_DIR/sitepoint
mkdir -p $SITEPOINT_DIR/shared-ubuntu-vagrant
pushd $SITEPOINT_DIR/sitepoint
vagrant init
rm Vagrantfile 
vagrant init ubuntu/xenial32
mv -f Vagrantfile Vagrantfile.$$
sed -e '/synced_folder/s/# config/config/' Vagrantfile.$$ > Vagrantfile
mv -f Vagrantfile Vagrantfile.$$
sed -e '/synced_folder/s/data/shared-ubuntu-vagrant/' Vagrantfile.$$ > Vagrantfile
vagrant up
popd
mkdir -p ~/.ssh

key_file=$SITEPOINT_DIR/sitepoint/.vagrant/machines/default/virtualbox/private_key
if [ ! -f "$key_file" ]; then
    echo "File '${key_file}' not found."
    exit 1
fi
ln -sfn $key_file ~/.ssh/id_vg

ssh-keygen -R "[127.0.0.1]:2222"
status=$(ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ~/.ssh/id_vg vagrant@127.0.0.1 -p 2222 echo ok 2>&1 | tail -n1)
echo $status
if [[ $status == "ok" ]] ; then
    echo "SSH Success"
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i ~/.ssh/id_vg vagrant@127.0.0.1 -p 2222 2>&1 "
        echo vagrant | sudo -S apt-get -y update; 
        sudo apt-get -y dist-upgrade;
        sudo apt-get -y upgrade;
        sudo apt-get install -y tcsh;
        echo vagrant | chsh -s /bin/tcsh;
        sudo apt-get install -y zip gdb libssl-dev xorg gnome-terminal xterm evince libreoffice;
    "
    echo "export DISPLAY=:0" >> ~/.bashrc
    source ~/.bashrc
else
    echo "SSH Failed with status: $status"
    exit 1
fi

clear
echo -e "Install Successful."
echo -e "Login via SSH: ssh -i ~/.ssh/id_vg vagrant@127.0.0.1 -p 2222"
echo -e "Test xterm: (xquartz &) && sleep 10 && ssh -X -Y -i ~/.ssh/id_vg vagrant@127.0.0.1 -p 2222 xclock"