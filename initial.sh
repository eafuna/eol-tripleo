#!/bin/bash

# Create 'stack' user and add it to sudoers
useradd stack
passwd stack
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

# CentOS, disable subscription as this is not needed
sed -i -e 's/abc/XYZ/g' /etc/yum/pluginconf.d/subscription-manager.conf

su – stack

export VIRTHOST=127.0.0.2

# https://github.com/openstack-archive/tripleo-quickstart.git
git clone https://github.com/eafuna/tripleo-quickstart-eol-update.git tripleo-quickstart