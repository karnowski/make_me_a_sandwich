#!/usr/bin/env bash

# TODO: generated boilerplate should include the Design Principles here

PROJECT_NAME=application

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

function exit_if_any_statement_fails {
  set -e
}

function skipping {
  local msg=$1
  printf "\e[0;32m[skipping]\e[00m $msg\n"
}

function installing {
  local msg=$1
  printf "\e[1;33m[installing]\e[00m $msg\n"
}

function checking {
  local msg=$1
  printf "\e[1;33m[checking]\e[00m $msg\n"
}

function update_and_upgrade {
  checking "update and upgrade OS"
  aptitude update
  aptitude upgrade -y
}

function ensure_fundamentals {
  checking "fundamental packages"
  aptitude install -y vim openssh-client wget python-software-properties
}

function setup_firewall {
  checking "firewall"
  aptitude install -y ufw
  ufw default deny
  ufw allow 22
  ufw allow 80
  ufw allow 443
  ufw --force enable
}

function install_build_from_source_prereqs {
  checking "packages for software compilation"
  aptitude install -y build-essential libssl-dev libreadline6-dev zlib1g-dev libxml2-dev libxslt-dev
}

function install_git {
  checking "git"
  aptitude install -y git-core
}

function install_ruby {
  if [ -x /usr/local/bin/ruby ]; then
    skipping "Already installed: ruby"
  else
    installing "ruby"
    pushd /tmp
    
    if [ ! -d ruby-1.9.2-p290 ]; then
      wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz
      tar --no-same-owner -zxf ruby-1.9.2-p290.tar.gz
    fi
    
    cd ruby-1.9.2-p290
    ./configure
    make
    make install
    popd
  fi
}

function install_essential_gems {
  checking "essential Ruby gems"
  gem update --system
  gem install rake --no-rdoc --no-ri --version 0.9.2
  gem install bundler --no-rdoc --no-ri --version 1.0.18
}

# function install_ree_and_passenger {
#   # TODO: needs to be idempotent-ized
#   wget http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise_1.8.7-2011.03_i386_ubuntu10.04.deb
#   dpkg -i ruby-enterprise_1.8.7-2011.03_i386_ubuntu10.04.deb 
#   passenger-install-apache2-module 
# }

function install_postgresql {
  if [ -f /etc/postgresql/8.4/main/pg_hba.conf ]; then
    skipping "Already installed: postgresql"
  else
    installing "postgres"
    aptitude install -y postgresql-8.4 postgresql-server-dev-8.4

    # Allows postgres user to connect.
    sed -ie 's/ident$/trust/' /etc/postgresql/8.4/main/pg_hba.conf
  fi
}

function install_mysql {
  checking "MySQL"
  export DEBIAN_FRONTEND=noninteractive
  aptitude install -y mysql-server libmysqlclient16-dev
  unset DEBIAN_FRONTEND
}

function install_mongodb {
  if [ -f '/etc/apt/sources.list.d/10gen' ]; then
    skipping "Already installed: mongodb"
  else
    installing "mongodb"
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
    cp 10gen.sources.list /etc/apt/sources.list.d/10gen
    aptitude install -y mongodb-10gen
  fi
}

function install_self_signed_cert {
  if [ -f '/etc/ssl/certs/apache2.pem' ]; then
    skipping "Already installed: self-signed cert"
  else
    installing "self-signed cert"
    mkdir -p /etc/ssl/certs
    openssl req \
      -x509 -nodes -days 3650 \
      -subj "/C=US/ST=North Carolina/L=Durham/CN=${PROJECT_NAME}" \
      -newkey rsa:1024 \
      -keyout /etc/ssl/certs/apache2.pem \
      -out /etc/ssl/certs/apache2.pem
  fi
}

function install_apache2 {
  checking "Apache2"
  aptitude install -y apache2 libcurl4-openssl-dev libssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev
}

function install_apache_config {
  if [ -f "/etc/apache2/sites-enabled/${PROJECT_NAME}" ]; then
    skipping "Apache config already installed."
  else
    installing "Apache conf"
    cp apache-site.conf /etc/apache2/sites-available/${PROJECT_NAME}
    a2enmod ssl
    a2enmod rewrite
    a2dissite default
    a2ensite $PROJECT_NAME
  fi
}

function restart_apache {
  checking "Restarting Apache"
  /etc/init.d/apache2 restart
}

# Note this is tied to the Ruby 1.9.2 installation above
# If you're using REE, it will install passenger itself.
function install_passenger {
  # (nevermind the 1.9.1 below, it's a red-herring; this is really 1.9.2)  
  if [ -f /usr/local/lib/ruby/gems/1.9.1/gems/passenger-3.0.8/ext/apache2/mod_passenger.so ]; then
    skipping "Already installed: passenger"
  else
    installing "passenger"
    gem install --no-rdoc --no-ri passenger --version 3.0.8
    passenger-install-apache2-module -a
  fi
}

# function install_logrotate {
#   if [ -f /etc/logrotate.d/${PROJECT_NAME} ]; then
#     skipping "Already installed: logrotate configuration"
#   else
#     installing "logrotate configuration"
# 
#     # install our config that rotates logs from Rails, Apache, mail, etc.
#     cp ${PROJECT_NAME}.logrotate /etc/logrotate.d/${PROJECT_NAME}
#   fi
# }

function install_nodejs {
  if [ -x /usr/bin/node ]; then
    skipping "Already installed: nodejs"
  else
    installing "nodejs"
    pushd /tmp
    
    if [ ! -d node-v0.5.5 ]; then
      wget http://nodejs.org/dist/v0.5.5/node-v0.5.5.tar.gz
      tar --no-same-owner -zxvf node-v0.5.5.tar.gz
    fi
    
    cd node-v0.5.5
    ./configure
    make
    make install
    popd
    ln -s /usr/local/bin/node /usr/bin/node
  fi
}

function bootstrap_webapp {
  update_and_upgrade
  ensure_fundamentals
  setup_firewall
  install_build_from_source_prereqs
  install_git
  
  install_postgresql
  install_mysql
  install_mongodb
  
  install_ruby
  # install_ree_and_passenger
  install_essential_gems
  
  install_apache2
  install_passenger
  install_apache_config
  install_self_signed_cert
  restart_apache

  # install_logrotate

  install_nodejs

  echo "Work complete!"
}

exit_if_any_statement_fails
bootstrap_webapp
