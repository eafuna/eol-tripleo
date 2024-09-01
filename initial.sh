#!/bin/bash

# sudo -i JUST TO MAKE SURE WE HAVE ALL PRIV. DO NOT SKIP!
# curl -O https://raw.githubusercontent.com/eafuna/eol-tripleo/main/initial.sh

user=`whoami`

if [ "$user" == "root" ]
    # REQUIRES:
    #       - curl

    # Create 'stack' user and add it to sudoers
    useradd stack && (echo "undercloud"; echo "undercloud") | passwd stacksh
    echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
    chmod 0440 /etc/sudoers.d/stack
    sudo -u stack initial.sh
fi 

if [ "$user" == "stack" ]
    # CentOS, disable subscription as this is not needed
    sed -i -e 's/enabled\=1/enable\=0/g' /etc/yum/pluginconf.d/subscription-manager.conf
    cat /etc/yum/pluginconf.d/subscription-manager.conf

    yum install git -y

    export VIRTHOST=127.0.0.2

    # https://github.com/openstack-archive/tripleo-quickstart.git
    git clone https://github.com/eafuna/tripleo-quickstart-eol-update.git tripleo-quickstart
if