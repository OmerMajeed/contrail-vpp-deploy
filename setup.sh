#!/bin/bash

git clone https://github.com/OMajeed/contrail-ansible-deployer
git clone https://github.com/OMajeed/contrail-kolla-ansible
cd contrail-kolla-ansible
git checkout contrail/ocata
cd ..
