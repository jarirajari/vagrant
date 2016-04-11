# Jenkins
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sh -c "echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list"
apt-get update
apt-get -y install jenkins

JENKINS_USER=$NAME
JENKINS_GROUP=$NAME

if [ -f /etc/default/jenkins ] ; then
  sed -i 's/HTTP_PORT=8080/HTTP_PORT=8081/g' /etc/default/jenkins
  sed -i 's/JENKINS_ARGS=""/JENKINS_ARGS="--prefix=/jenkins  --javahome=$JAVA_HOME"/g' /etc/default/jenkins
  sed -i 's/JENKINS_USER=$NAME/JENKINS_USER=vagrant/g' /etc/default/jenkins
  sed -i 's/JENKINS_GROUP=$NAME/JENKINS_GROUP=vagrant/g' /etc/default/jenkins
  sudo echo "Include /etc/apache2/jenkins-apache.conf" >> /etc/apache2/apache2.conf
  sudo cp /vagrant/configurations/environment/lo/platform/default/confs/jenkins-apache.conf /etc/apache2/

  sudo /etc/init.d/jenkins restart
  echo "Jenkins installed"
fi
