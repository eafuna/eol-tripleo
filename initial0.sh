#!/bin/bash

# sudo -i JUST TO MAKE SURE WE HAVE ALL PRIV. DO NOT SKIP!
# curl -O https://raw.githubusercontent.com/eafuna/eol-tripleo/main/initial.sh
echo "----------------> RUNNING INITIALIZATION SEQUENCE"
user=$(whoami)
os=$(cat /etc/os-release | grep -o "CentOS")

if [ "$user" == "root" ]; then

    # IMPORTANT! Make sure time is properly configured, otherwise, Certificates will fail which
    # will result to broken packages. Additional requirement is the NTP must have been properly 
    # configured. See https://docs.openstack.org/install-guide/environment-ntp-verify.html

    # We are using here google to extract current date 
    date -s "$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"
    
    # disable plugin subscription on CentOS only
    source /etc/os-release
    os=$("$NAME" | grep -o "CentOS")
    if [ "$os"=="CentOS" ]; then   
        echo "CentOS detected; updating subscription disabled" 
        sed -i -e 's/enabled\=1/enable\=0/g' /etc/yum/pluginconf.d/subscription-manager.conf
    fi 

    # creating user 'stack', skip whole process if done
    # idealy this should script should run only once
    getent passwd stack > /dev/null 2&>1
    if [ $? -eq 0 ]; then
        echo "..... Stack user exists. Skipping creation"
    else

        # CHANGE PASSWORD!
        echo "Stack user not exist. Creating"
        useradd stack && (echo "undercloud"; echo "undercloud") | passwd stack

        echo "Promote stack as sudoer setting nopasswd when logged"
        echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
        chmod 0440 /etc/sudoers.d/stack

    fi    

    # Idealy, this should be run upon creating the user. We are only doing this here to accomodate re-runs where we have already created
    # the stack user. In this case we need to make sure we have the updated scripts from git and copy this into the 
    # directory of the 'stack'
    echo "Copy initial script to stack home"
    # this part deletes the tripleo directory of 'stack' if it exists. Easier that way rather than run another git pull or synch there 
    [[ -d /home/stack/tripleo-quickstart ]] && sudo rm -r /home/stack/tripleo-quickstart && echo "..removed existing stack tripleo directory"  
    (cd /root/tripleo-quickstart && git pull)
    cp -R /root/tripleo-quickstart /home/stack/
    # make sure 'stack' owns this scripts for execution    
    chown -R stack:stack /home/stack/tripleo-quickstart

    # We deprecated this method since it appears it is cached, hence, not updated 
    # curl -O https://raw.githubusercontent.com/eafuna/eol-tripleo/main/initial.sh /home/stack/

    # This section now loads this exact same script executing it on 'stack' perspective. 
    echo "...$(whoami) will now give control to another user to run the installation "
    sudo -u stack /home/stack/tripleo-quickstart/initial0.sh
    echo "...[DEBUG] Should have run the install dependencies above this line. Since I am now a $(whoami)"
    pwd 

fi 

if [ "$user" == "stack" ]; then

    echo "...Running this now as $(whoami)"

    # adding its stack bin to PATH; 
    # remember to set this instead in bashrc
    export PATH="$PATH:/home/stack/.local/bin;"
    export VIRTHOST="127.0.0.2"    

    cd /home/stack/tripleo-quickstart/

    cat << EOF 
    Current Path: $PATH
    Current User: $(whoami)
    Working Directory: $(pwd)
EOF

    bash quickstart.sh --install-deps

    # https://github.com/openstack-archive/tripleo-quickstart.git
    # git clone "https://github.com/eafuna/eol-tripleo.git" tripleo-quickstart
fi