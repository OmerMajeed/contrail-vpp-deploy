#!/bin/bash

git clone https://github.com/OmerMajeed/contrail-ansible-deployer
git clone https://github.com/OmerMajeed/contrail-kolla-ansible
cd contrail-kolla-ansible
git checkout contrail/ocata
cd ..
