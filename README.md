# contrail-vpp-deploy
These set of playbooks deploys contrail with letting the user pick dataplane from vrouter and VPP. This deployment is micro service based, and for every service there would be a separate container. In configuration file user could specify whether to deploy vrouter or VPP as a dataplane.

# Versions and Openstack flavors
This deployer is tested to be working with Centos 7.5.1804 (kernel version 3.10.0-862.3.2.el7.x86_64) and Centos 7.6.1810 (kernel version 3.10.0-957.1.3.el7.x86_64).
This deployment would deploy Contrail 5.0 with VPP 18.04, and openstack flavor ocata.

Note: If you are going for a multinode deployment make sure each node has a unique hostname.



# 1. Deployment process

### 1.0 Install pre-requisite packages
The following set of commands would get you the ansible scripts that would deploy contrail with the dataplane of your liking.
```
yum -y install epel-release
yum install -y python-pip
pip install requests
```

### 1.1 Install ansible
```
yum -y install git ansible-2.4.2.0
```
### 1.2 Get the deployer
```
cd
git clone https://github.com/Sofioni/contrail-vpp-deploy
./setup.sh
cd contrail-ansible-deployer
```

### 1.3 Configure necessary parameters before starting off with deployment
Here's the basic configuration for a multinode deployment

```
provider_config:
  bms:
    ssh_user: root
    ssh_pwd: <password>
    ntpserver: 210.173.160.27
    domainsuffix: localdomain

instances:
  bms1:
    provider: bms
    ip: <BMS1 IP>
    roles:
      config_database:
      config:
      control:
      analytics_database:
      analytics:
      webui:
      openstack:
  bms2:
    provider: bms
    ip: <BMS2 IP>
    roles:
      vpp:
        VPP_CONTROL_ADDR: <control interface IP, same subnet as of BMS>
        PHYSICAL_INTERFACE: enp2s0f1
        AGENT_MODE: dpdk
        HUGE_PAGES: 10240
      openstack_compute:
  bms3:
    provider: bms
    ip: <BMS3 IP>
    roles:
      vrouter:
        PHYSICAL_INTERFACE: enp2s0f1
        AGENT_MODE: dpdk
        HUGE_PAGES: 10240
      openstack_compute:
contrail_configuration:
  CONTRAIL_VERSION: ocata-v1
  RABBITMQ_NODE_PORT: 5673
  ENCAP_PRIORITY: VXLAN,MPLSoGRE,MPLSoUDP
  PHYSICAL_INTERFACE: enp2s0f1
  AUTH_MODE: keystone
  KEYSTONE_AUTH_URL_VERSION: /v3
kolla_config:
  kolla_globals:
    network_interface: "enp2s0f1"
    kolla_external_vip_interface: "enp2s0f1"
    enable_swift: no
    enable_haproxy: no
  kolla_passwords:
    keystone_admin_password: <keystone admin password>
global_configuration:
  CONTAINER_REGISTRY: sofioni
  REGISTRY_PRIVATE_INSECURE: True
```

### 1.4 Install contrail and Kolla requirements

The following playbook installs packages on the deployer as well as the other target hosts requiring contrail, VPP and kolla containers.

```
ansible-playbook -i inventory/ -e orchestrator=openstack playbooks/configure_instances.yml
```

# 2. Deploy Contrail, VPP and Kolla containers

```
ansible-playbook -i inventory/ playbooks/install_openstack.yml
ansible-playbook -i inventory/ -e orchestrator=openstack playbooks/install_contrail.yml
```
