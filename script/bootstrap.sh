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

# T2 stuff starts here:
if [ ! -f /vagrant/.env ]; then
    su - vagrant -c 'cp /vagrant/.env{.sample,}'
fi

if [ ! -f /vagrant/config/database.yml ]; then
    su - vagrant -c 'cp /vagrant/config/database{.sample,}.yml'
fi


if grep -i "GOOGLE_CLIENT_ID" ~/.bashrc; then
    echo "Google Client ID already set"
else
    su - vagrant -c 'echo "export GOOGLE_CLIENT_ID=\"480140443980.apps.googleusercontent.com\"" >> ~/.bashrc'
fi

if grep -i "GOOGLE_CLIENT_ID" ~/.bashrc; then
    echo "Google Secret already set"
else
    su - vagrant -c 'echo "export GOOGLE_SECRET=\"v03dRPvKlgn_OsK79MXSDn5j\"" >>  ~/.bashrc'
fi

if [ -f /vagrant/Gemfile.lock ]; then
  rm /vagrant/Gemfile.lock
fi

su - vagrant -c 'cd /vagrant && bundle'
su - vagrant -c 'cd /vagrant && foreman run rake db:create:all'
su - vagrant -c 'cd /vagrant && foreman run rake db:schema:load'
su - vagrant -c 'cd /vagrant && ./.git_remotes_setup.sh'
su - vagrant -c 'rake db:refresh_from_production'
