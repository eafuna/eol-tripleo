#!/bin/bash

# sudo -i JUST TO MAKE SURE WE HAVE ALL PRIV. DO NOT SKIP!
# curl -O https://raw.githubusercontent.com/eafuna/eol-tripleo/main/initial.sh

user=`whoami`

if [ "$user" == "root" ]; then
    # REQUIRES:
    #       - curl

    # Create 'stack' user and add it to sudoers
    useradd stack && (echo "undercloud"; echo "undercloud") | passwd stack
    echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
    #curl -O https://raw.githubusercontent.com/eafuna/eol-tripleo/main/initial.sh /home/stack/  
    chmod 0440 /etc/sudoers.d/stack
    echo "invoking stack to run initial script"
    pwd 
    sudo -u stack /root/initial.sh
    # curl -O https://raw.githubusercontent.com/eafuna/eol-tripleo/main/initial.sh 
    # chmod +x initial.sh
fi 

if [ "$user" == "stack" ]; then
    # CentOS, disable subscription as this is not needed
    sed -i -e 's/enabled\=1/enable\=0/g' /etc/yum/pluginconf.d/subscription-manager.conf
    cat /etc/yum/pluginconf.d/subscription-manager.conf

    yum install git -y

    export VIRTHOST="127.0.0.2"

    # https://github.com/openstack-archive/tripleo-quickstart.git
    git clone "https://github.com/eafuna/eol-tripleo.git" tripleo-quickstart
if