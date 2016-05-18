#!/usr/bin/env bash

# Install some basic tools
apt-get -y install openssl libssl-dev curl htop links unzip

# OpenJDK 8 (in Ubuntu 16.04+)
add-apt-repository -y ppa:openjdk-r/ppa
apt-get -y update
apt-get -y install openjdk-8-jdk
sudo update-alternatives --config java
sudo update-alternatives --config javac
sudo echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/profile
echo "OpenJDK installed"

# Maven
apt-get -y install maven
sudo echo "export M2_HOME=/usr/share/maven" >> /etc/profile
sudo echo "export MAVEN_HOME=/usr/share/maven" >> /etc/profile
echo "Maven installed"

#  Wildfly
WILDFLY_VERSION="10.0.0.Final"
WILDFLY_TAR_GZ="wildfly-$WILDFLY_VERSION.tar.gz"
WILDFLY_DOWNLOAD_URL="http://download.jboss.org/wildfly/$WILDFLY_VERSION/$WILDFLY_TAR_GZ"
WILDFLY_EXTRACT="wildfly-$WILDFLY_VERSION"
WILDFLY_INSTALL_DIR="/opt/wildfly-versions/"
WILDFLY_HOME="/opt/wildfly"
WILDFLY_SYSTEM_USER="wildfly"
WILDFLY_SYSTEM_PASSWORD="wildfly"
WILDFLY_SERVICE="wildfly"
WILDFLY_SERVICE_CONF="/etc/default/wildfly.conf"
WILDFLY_LOG="/var/log/wildfly"

# Create user first! (With login: useradd -p $(openssl passwd -1 ${WILDFLY_SYSTEM_PASSWORD}) ${WILDFLY_SYSTEM_USER})
useradd -s /sbin/nologin $WILDFLY_SYSTEM_USER

mkdir -p $WILDFLY_INSTALL_DIR
wget --progress=bar:force $WILDFLY_DOWNLOAD_URL
tar -zxf $WILDFLY_TAR_GZ
mv $WILDFLY_EXTRACT $WILDFLY_INSTALL_DIR
rm -f $WILDFLY_TAR_GZ
echo "export WILDFLY_HOME=$WILDFLY_HOME" >> ~/.profile
mkdir -p $WILDFLY_LOG

sudo ln -s "$WILDFLY_INSTALL_DIR/$WILDFLY_EXTRACT" "$WILDFLY_HOME"
sudo chown ${WILDFLY_SYSTEM_USER}:${WILDFLY_SYSTEM_USER} ${WILDFLY_HOME}
sudo chown -R ${WILDFLY_SYSTEM_USER}:${WILDFLY_SYSTEM_USER} ${WILDFLY_INSTALL_DIR}
sudo chown -R ${WILDFLY_SYSTEM_USER}:${WILDFLY_SYSTEM_USER} ${WILDFLY_LOG}

cp /vagrant/configurations/environment/lo/platform/wildfly/scripts/wildfly-init-debian.sh /etc/init.d/$WILDFLY_SERVICE
cp /vagrant/configurations/environment/lo/platform/wildfly/confs/wildfly.conf /etc/default/wildfly
sed -i -e 's,<inet-address value="${jboss.bind.address:127.0.0.1}"/>,<any-address/>,g' $WILDFLY_INSTALL_DIR/$WILDFLY_EXTRACT/standalone/configuration/standalone.xml
sed -i -e 's,<inet-address value="${jboss.bind.address.management:127.0.0.1}"/>,<any-address/>,g' $WILDFLY_INSTALL_DIR/$WILDFLY_EXTRACT/standalone/configuration/standalone.xml
chmod 755 /etc/init.d/$WILDFLY_SERVICE
sudo update-rc.d $WILDFLY_SERVICE defaults
sudo update-rc.d $WILDFLY_SERVICE enable
sudo service $WILDFLY_SERVICE start
echo "Wildfly installed to \"$WILDFLY_INSTALL_HOME\""

# PostgreSQL
PG_VERSION="9.4"
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

export DEBIAN_FRONTEND=noninteractive
add-apt-repository "deb https://apt.postgresql.org/pub/repos/apt trusty-pgdg main" 
wget --quiet -O - https://postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - 
apt-get -y update
apt-get -y upgrade
apt-get -y install postgresql-${PG_VERSION} postgresql-contrib-${PG_VERSION}

if [ -d /etc/postgresql ] ; then
  # Edit postgresql.conf to change listen address to '*':
  sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
  # Append to pg_hba.conf to add password auth:
  echo "host    all             all             all                     md5" >> "$PG_HBA"
  # Explicitly set default client_encoding
  echo "client_encoding = utf8" >> "$PG_CONF"

  sudo service postgresql restart
  echo "PostgreSQL installed"
fi

# Apache2 (note! /var/www/html not /var/www )
apt-get -y install apache2
apt-get -y install libapache2-mod-proxy-html
sudo sed -i 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=vagrant/g' /etc/apache2/envvars
sudo sed -i 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=vagrant/g' /etc/apache2/envvars
if ! [ -L /var/www/html ] ; then
  rm -rf /var/www/html
  ln -fs /vagrant /var/www/html
fi

sudo a2enmod proxy
sudo a2enmod proxy_http 
sudo a2enmod cgi
sudo a2enmod env
sudo a2enmod alias
sudo apachectl restart
echo "Apache installed"

# Jenkins
#source bootstrap-jenkins.sh

# Git
apt-get -y install git
git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?
# ...
if [ $GIT_IS_AVAILABLE -eq 0 ] && [ -d /var/www/html ] ; then 
  git config http.receivepack true
  git init --bare --shared /var/www/html/git/repos/repo.git
  sudo echo "Include /etc/apache2/git-apache.conf" >> /etc/apache2/apache2.conf
  sudo cp /vagrant/configurations/environment/lo/platform/default/confs/git-apache.conf /etc/apache2/
  echo "Git installed"
fi

# Platform
sudo service apache2 restart
echo "Platform installed"
