#!/usr/bin/env bash

# TODO: include the Design Principles here

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

function ensure_fundamentals {
  aptitude update
  aptitude upgrade -y
  aptitude install -y vim openssh-client wget python-software-properties
}

function setup_firewall {
  aptitude install -y ufw
  ufw default deny
  ufw allow 22
  ufw allow 80
  ufw allow 443
  ufw --force enable
}

function install_build_from_source_prereqs {
  aptitude install -y build-essential libssl-dev libreadline6-dev zlib1g-dev libxml2-dev libxslt-dev
}

function install_git {
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
      tar zxf ruby-1.9.2-p290.tar.gz
    fi
    
    cd ruby-1.9.2-p290
    ./configure
    make
    make install
    popd
  fi
}

function install_essential_gems {
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

# function install_postgresql {
#   if [ -f /var/lib/pgsql/data/pg_hba.conf ]; then
#     skipping "Already installed: postgresql"
#   else
#     installing "postgres"
#     yum -y install postgresql-server postgresql-devel
#     service postgresql initdb
# 
#     # Allows postgres user to connect.
#     sed -ie 's/ident$/trust/' /var/lib/pgsql/data/pg_hba.conf
# 
#     chkconfig postgresql on
#     service postgresql start
#   fi
# }

function install_mysql {
  export DEBIAN_FRONTEND=noninteractive
  aptitude install -y mysql-server libmysqlclient16-dev
  unset DEBIAN_FRONTEND
}

# 
# function install_mongodb {
#   if [ -f '/etc/yum.repos.d/10gen.repo' ]; then
#     skipping "Already installed: mongodb"
#   else
#     installing "mongodb"
#     cp 10gen.yum.repo /etc/yum.repos.d/10gen.repo
#     yum -y --enablerepo=10gen install mongo-10gen-server
#     chkconfig mongod on
#     service mongod start
#   fi
# }
# 
# function install_self_signed_cert {
#   if [ -f '/etc/ssl/self_signed.pem' ]; then
#     skipping "Already installed: self-signed cert"
#   else
#     installing "self-signed cert"
#     mkdir -p /etc/ssl    
#     openssl req \
#       -x509 -nodes -days 3650 \
#       -subj "/C=US/ST=North Carolina/L=Durham/CN=${PROJECT_NAME}" \
#       -newkey rsa:1024 \
#       -keyout /etc/ssl/self_signed.pem \
#       -out /etc/ssl/self_signed.pem
#   fi
# }

function install_apache2 {
  aptitude install -y apache2 libcurl4-openssl-dev libssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev
}

# function install_apache_config {
#   conf="${PROJECT_NAME}.conf"
#   
#   if [ -f "/etc/httpd/conf.d/${conf}" ]; then
#     skipping "${conf} already installed."
#   else
#     installing "${conf}" 
#     cp ${conf} /etc/httpd/conf.d
#     cp valid_apache_users /etc/httpd/valid_users
#   fi

    # -- from abedra:
    # ln -sf /var/www/apps/mydischargepro/current/config/apache2/mydischargepro.conf
    # a2dissite default
    # a2ensite mydischargepro.conf
    # /etc/init.d/apache2 restart
# }
# 
# function start_apache {
#   service httpd start
# }

# Note this is tied to the Ruby 1.9.2 installation above (nevermind the 1.9.1 below, it's a red-herring).
# If you're using REE, it will install passenger itself.
function install_passenger {
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
# 
# function install_nodejs {
#   if [ -x /usr/bin/node ]; then
#     skipping "Already installed: nodejs"
#   else
#     installing "nodejs"
#     wget http://nodejs.org/dist/node-v0.4.10.tar.gz
#     tar zxvf node-v0.4.10.tar.gz
#     cd node-v0.4.10
#     ./configure
#     make
#     make install
#     cd -
#     ln -s /usr/local/bin/node /usr/bin/node
#   fi
# }
# 
# function create_user {
#   local username=$1
#   local shell=$2
#     
#   if id $username > /dev/null; then
#     skipping "user already exists: $username";
#   else
#     installing "user: $username with shell: $shell"
#     useradd --create-home --shell $shell $username;
#     passwd -d $username;
#     chage -E -1 -I -1 -M -1 -m -1 -W -1 $username;
#   fi
# }

function bootstrap_webapp {
  ensure_fundamentals
  setup_firewall
  install_build_from_source_prereqs
  install_git
  
  # install_postgresql
  install_mysql
  # install_mongodb
  
  install_ruby
  # install_ree_and_passenger
  install_essential_gems
  
  install_apache2
  install_passenger
  # install_apache_config
  # install_self_signed_cert
  # start_apache

  # install_logrotate

  # install_nodejs

  echo "Work complete!"
}

exit_if_any_statement_fails
bootstrap_webapp
