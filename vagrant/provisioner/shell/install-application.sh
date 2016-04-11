#!/usr/bin/env bash

# PostgreSQL
ADM_DB_USERNAME=admin
ADM_DB_PASSWORD=admin
APP_DB_NAME=applicationDB
APP_DB_USERNAME=wfdb
APP_DB_PASSWORD=wildfly

print_db_usage () {
  echo "Your PostgreSQL database has been setup and can be accessed on your local machine on the forwarded port (default: 15432)"
  echo "  Host: localhost"
  echo "  Port: 15432"
  echo "  Database: $APP_DB_NAME"
  echo "  Username: $APP_DB_USERNAME"
  echo "  Password: $APP_DB_PASSWORD"
  echo ""
  echo "Admin access to postgres user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo ""
  echo "psql access to app database user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo "  PGUSER=$APP_DB_USERNAME PGPASSWORD=$APP_DB_PASSWORD psql -h localhost $APP_DB_NAME"
  echo ""
  echo "Env variable for application development:"
  echo "  DATABASE_URL=postgresql://$APP_DB_USERNAME:$APP_DB_PASSWORD@localhost:15432/$APP_DB_NAME"
  echo ""
  echo "Local command to access the database via psql:"
  echo "  PGUSER=$APP_DB_USERNAME PGPASSWORD=$APP_DB_PASSWORD psql -h localhost -p 15432 $APP_DB_NAME"
}

service postgresql restart

cat << EOF | su - postgres -c psql
-- Create the database user:
CREATE USER $APP_DB_USERNAME WITH PASSWORD '$APP_DB_PASSWORD';

-- Create the database:
CREATE DATABASE $APP_DB_NAME WITH OWNER=$APP_DB_USERNAME 
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;
EOF
print_db_usage
echo "Finished setting up Postgresql"

#Wildfly
WILDFLY_USERNAME=wfadmin
WILDFLY_PASSWORD=wildfly
WILDFLY_HOME=/opt/wildfly
WILDFLY_SCRIPTS=/vagrant/configurations/environment/lo/application/wildfly/cli
WILDFLY_CREDENTIALS="--user=$WILDFLY_USERNAME --password=$WILDFLY_PASSWORD"
WILDFLY_USER="wildfly"

# Add management user for remote deploys and Admin GUI
sudo -u $WILDFLY_USER $WILDFLY_HOME/bin/add-user.sh --silent=true $WILDFLY_USERNAME $WILDFLY_PASSWORD
# Add application user
sudo -u $WILDFLY_USER $WILDFLY_HOME/bin/add-user.sh --silent=true -a wfuser wildfly

sudo -u $WILDFLY_USER $WILDFLY_HOME/bin/jboss-cli.sh --file=$WILDFLY_SCRIPTS/install-postgresql-module.cli $WILDFLY_CREDENTIALS
sudo -u $WILDFLY_USER $WILDFLY_HOME/bin/jboss-cli.sh --file=$WILDFLY_SCRIPTS/install-jdbc-driver.cli $WILDFLY_CREDENTIALS
sudo -u $WILDFLY_USER $WILDFLY_HOME/bin/jboss-cli.sh --file=$WILDFLY_SCRIPTS/install-jdbc-driver-datasource.cli $WILDFLY_CREDENTIALS

sudo service wildfly restart
echo "Finished setting up Wildfly"
