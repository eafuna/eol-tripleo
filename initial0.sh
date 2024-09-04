#!/bin/bash

# sudo -i JUST TO MAKE SURE WE HAVE ALL PRIV. DO NOT SKIP!
# curl -O https://raw.githubusercontent.com/eafuna/eol-tripleo/main/initial.sh
echo "----------------> RUNNING INITIALIZATION SEQUENCE"
user=`whoami`
os=$(cat /etc/os-release | grep -o "CentOS")

if [ "$user" == "root" ]; then
    
    source /etc/os-release
    os=$("$NAME" | grep -o "CentOS")
    if [ "$os"=="CentOS" ]; then   
        echo "CentOS detected; updating subscription disabled" 
        sed -i -e 's/enabled\=1/enable\=0/g' /etc/yum/pluginconf.d/subscription-manager.conf
        # cat /etc/yum/pluginconf.d/subscription-manager.conf
    fi 

    getent passwd stack > /dev/null 2&>1
    if [ $? -eq 0 ]; then
        echo "..... Stack user exists. Skipping creation"
    else
        echo "Stack user not exist. Creating"
        useradd stack && (echo "undercloud"; echo "undercloud") | passwd stack

        echo "Copy initial script to stack home"
        cp -R /root/tripleo-quickstart /home/stack/
        chown -R stack:stack /home/stack/tripleo-quickstart

        # adding its stack bin to PATH
        export PATH="$PATH:/home/stack/.local/bin;"

        # extract time from google 
        # IMPORTANT! Make sure NTP is available and properly configured, otherwise, Certificates will fail which
        # will result to broken packages
        date -s "$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"

        echo "Promote stack as sudoer setting nopasswd when logged"
        echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
        chmod 0440 /etc/sudoers.d/stack

    fi    

    #curl -O https://raw.githubusercontent.com/eafuna/eol-tripleo/main/initial.sh /home/stack/  
    echo "Invoking stack to run initial script"
    whoami
    sudo -u stack /home/stack/tripleo-quickstart/initial0.sh
    echo "...[DEBUG] Should reach here quickly"
    pwd 
    # curl -O https://raw.githubusercontent.com/eafuna/eol-tripleo/main/initial.sh 
    # chmod +x initial.sh
fi 

if [ "$user" == "stack" ]; then
    # yum install git -y

    # exec su "$user" "$0" -- "$@"
    export VIRTHOST="127.0.0.2"    
    whoami
    pwd
    cd /home/stack/tripleo-quickstart/
    bash quickstart.sh --install-deps

    # https://github.com/openstack-archive/tripleo-quickstart.git
    # git clone "https://github.com/eafuna/eol-tripleo.git" tripleo-quickstart
fi