#!/usr/bin/env bash

# Docker on Ubuntu

#-------------------------- Docker Pre-requirements
#https://docs.docker.com/engine/installation/linux/ubuntulinux/

sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee -a /etc/apt/sources.list.d/docker.list
# linux-image-extra-* kernel packages
sudo apt-get -y update
sudo apt-get -y purge lxc-docker
# Verify that APT is pulling from the right repository
#apt-cache policy docker-engine
sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual

#-------------------------- Docker i.e. Docker Engine
sudo apt-get -y update
sudo apt-get -y install docker-engine
sudo service docker start

#-------------------------- Docker Compose
#https://docs.docker.com/compose/install/
#https://github.com/docker/compose/releases
DOCKER_COMPOSE=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9]+\.[0-9]+$" | tail -n 1` 
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose" 
sudo chmod +x /usr/local/bin/docker-compose 
echo "Installed Docker compose $DOCKER_COMPOSE"

#-------------------------- Docker Machine
#https://docs.docker.com/machine/install-machine/
#https://github.com/docker/machine/releases/
#http://linuxpitstop.com/install-and-use-command-line-tool-vboxmanage-on-ubuntu-16-04/
# But installing VBoxManage here (inside a virtual vagrant host) is not a good idea...
DOCKER_MACHINE=v0.8.2/docker-machine-`uname -s`-`uname -m`
sudo sh -c "curl -L https://github.com/docker/machine/releases/download/${DOCKER_MACHINE} >  /usr/local/bin/docker-machine"
sudo chmod +x /usr/local/bin/docker-machine
echo "Installed Docker machine $DOCKER_MACHINE"

#-------------------------- Docker installation check
echo ""
echo "Docker installation check"
echo ""
docker --version
docker-machine --version
docker-compose --version

#-------------------------- Python-pre-requirements initialize
# Python version is already 2.7.6, Python dev libs and pip
sudo apt-get -y install python-dev
sudo apt-get -y install python-pip
# virtualenv is a tool to create isolated Python environments
sudo pip install virtualenv
# Create 'venv-kubernetes'
sudo virtualenv venv-kubernetes
# Activate 'venv-kubernetes'
source venv-kubernetes/bin/activate
cd venv-kubernetes

#-------------------------- Python-Openstack --------------------------

cat > openstack_requirements.txt <<EOF
python-neutronclient==4.2.0
python-heatclient==1.2.0
python-novaclient==3.4.0
python-openstackclient==2.4.0
EOF
sudo pip install -r openstack_requirements.txt

#-------------------------- Python-Kubernetes --------------------------

cat > kubernetes_requirements.txt <<EOF
ansible==2.1
netaddr
python-neutronclient==4.2.0
python-heatclient==1.2.0
python-novaclient==3.4.0
python-openstackclient==2.4.0
shade==1.7.0
EOF
sudo pip install -r kubernetes_requirements.txt

#-------------------------- Python-pre-requirements finalize
cd ..
# Deactivate
deactivate
echo "Pre-requirements installed..."

cat > dm_help.txt <<EOF



***
* From http://blog.scottlowe.org/2015/08/04/using-vagrant-docker-machine-together/ Check slave IP address
* 
* docker-machine create -d generic \
* --generic-ssh-user vagrant \
* --generic-ssh-key <path to key: /vagrant/configurations/shared/ssh/insecure_private_key> \
* --generic-ip-address <IP address of VM> \
* <vm-name>
* 
* To connect your local Docker client to this newly-provisioned Docker Engine, run eval "$(docker-machine env <vm-name>)"
* From here, you can use all the standard Docker commands to pull images, launch containers, etc., using the local Docker client.
* Check result with "docker-machine ls". If you need to access a shell within the VM, you can use "docker-machine ssh <vm-name>"
*
* When you’re finished with the environment, or if you need to rebuild the environment for whatever reason, 
* run "docker-machine rm <vm-name>" to remove the VM from Docker Machine’s list of available Docker Engines
* 
* From instructions:
* #docker-machine create -d virtualbox slave
* #eval $(docker-machine env slave)
* #docker run hello-world
* #docker-machine rm -f slave
***



EOF
cat dm_help.txt
