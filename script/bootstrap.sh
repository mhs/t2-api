#!/usr/bin/env bash

apt-get update
apt-get install -y curl postgresql postgresql-contrib git libxml2-dev libxslt-dev libxml2-dev libpq-dev build-essential openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libv8-dev nodejs

# RVM and T2's Ruby
if [ -f /home/vagrant/.rvm ]; then
    echo 'RVM is already installed';
else
    su - vagrant -c 'curl -sSL https://get.rvm.io | bash -s stable --ruby=1.9.3-p484'
    su - vagrant -c 'source /home/vagrant/.rvm/scripts/rvm'; 
fi

# PostgreSQL
# echo "y" | sudo -u postgres createuser vagrant
# echo -e "postgres\npostgres" | passwd postgres
# su - postgres -c 'createdb t2api -O vagrant'
# su - vagrant -c "ruby /vagrant/script/config-db.rb"
echo "export LANGUAGE=en_US.UTF-8" >> /etc/bash.bashrc
echo "export LC_ALL=en_US.UTF-8" >> /etc/bash.bashrc
echo "export LANG=en_US.UTF-8" >> /etc/bash.bashrc

locale-gen en_US.UTF-8
dpkg-reconfigure locales

su - postgres -c "psql -c \"update pg_database set datistemplate=false where datname='template1';\""
su - postgres -c "psql -c 'drop database Template1;'"
su - postgres -c "psql -c \"create database template1 with owner=postgres encoding='UTF-8' lc_collate='en_US.utf8' lc_ctype='en_US.utf8' template template0;\""
su - postgres -c "psql -c \"update pg_database set datistemplate=true where datname='template1';\""

su - postgres -c "psql -c 'CREATE USER vagrant WITH CREATEDB CREATEROLE;'"

sed -i 's/md5/trust/g' /etc/postgresql/9.1/main/pg_hba.conf
sed -i 's/#listen/listen/g' /etc/postgresql/9.1/main/postgresql.conf

/etc/init.d/postgresql restart

# T2 stuff starts here:
if [ ! -f /vagrant/.env ]; then
    su - vagrant -c 'cp /vagrant/.env{.sample,}'
fi

if [ ! -f /vagrant/config/database.yml ]; then
    su - vagrant -c 'cp /vagrant/config/database{.sample,}.yml'
fi

if grep -i "GOOGLE_CLIENT_ID" /home/vagrant/.bashrc; then
    echo "Google Client ID already set"
else
    su - vagrant -c 'echo "export GOOGLE_CLIENT_ID=\"480140443980.apps.googleusercontent.com\"" >> ~/.bashrc'
    su - vagrant -c 'echo "GOOGLE_CLIENT_ID=\"480140443980.apps.googleusercontent.com\"" >> /vagrant/.env'
fi

if grep -i "GOOGLE_SECRET" /home/vagrant/.bashrc; then
    echo "Google Secret already set"
else
    su - vagrant -c 'echo "export GOOGLE_SECRET=\"v03dRPvKlgn_OsK79MXSDn5j\"" >>  ~/.bashrc'
    su - vagrant -c 'echo "GOOGLE_SECRET=\"v03dRPvKlgn_OsK79MXSDn5j\"" >>  /vagrant/.env'
fi

su - vagrant -c 'source ~/.bashrc'

if grep -i "RAILS_SECRET_KEY_BASE" /vagrant/.env; then
    echo "Secret key set"
else
    su - vagrant -c 'echo RAILS_SECRET_KEY_BASE=`cd /vagrant && rake secret` > /vagrant/.env'
fi

if [ -f /vagrant/Gemfile.lock ]; then
  rm /vagrant/Gemfile.lock
fi

su - vagrant -c 'cd /vagrant && bundle'
su - vagrant -c 'cd /vagrant && foreman run rake db:create:all'
su - vagrant -c 'cd /vagrant && foreman run rake db:schema:load'
su - vagrant -c 'cd /vagrant && ./.git_remotes_setup.sh'
su - vagrant -c 'cd /vagrant && rake db:refresh_from_production'
