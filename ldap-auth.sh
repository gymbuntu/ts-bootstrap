#!/bin/bash
#
# ts-bootstrap install a ltsp server with some dependencies
# mainly it enables ldap authentication using PAM-LDAP

# Ask for the administrator password upfront
sudo -v

BOOT="$(pwd)"

set -e

CONF="$BOOT/ldap-auth.conf"

# load the config file
[ -e "$CONF" ] || fail "Config file \"$CONF\" not found!"
source $CONF

##
# useful functions
##

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

info () {
  printf "  [ \033[00;34m..\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

##
# the main script
##

debconf() {
  sudo echo "ldap-auth-config ldap-auth-config/$1" | sudo debconf-set-selections
}

preconfigure() {
  # now some basic defaults
  debconf "move-to-debconf boolean true"
  debconf "override boolean true"
  debconf "pam_password select $LDAP_PASSWORD_HASH"
  debconf "dblogin boolean $LDAP_DB_LOGIN"
  # specific ldap server config below
  debconf "ldapns/ldap_version select $LDAP_VERSION"
  debconf "ldapns/ldap-server string $LDAP_SERVER"
  # bind settings below
  debconf "dbrootlogin boolean $LDAP_ROOT_LOGIN"
  debconf "ldapns/base-dn string $BASE_DN"
  debconf "rootbinddn string $BIND_DN"
  debconf "rootbindpw password $BIND_PASSWORD"
}

configure() {
  # enable libnss-ldap
  sudo auth-client-config -t nss -p lac_ldap
  success 'Configured libnss-ldap'
}


install() {
  info 'Installing LDAP Auth Module ...'

  preconfigure

  sudo apt-get install -y -q libnss-ldap ecryptfs-utils >/dev/null
  success 'Installed libnss-ldap and ecryptfs-utils'

  configure

  # sudo sh -c 'echo "session required        pam_mkhomedir.so skel=/etc/skel/ umask=0022" >> /etc/pam.d/common-session'
  # success 'Activated automatic home directory creation'
}

remove() {
  info 'Removing (purging) LDAP Auth Module ...'

  sudo apt-get purge -y -q libnss-ldap ecryptfs-utils >/dev/null
  success 'Removed libnss-ldap and ecryptfs-utils'
}

reconfigure() {
  info 'Reconfiguring LDAP Auth Module ...'

  preconfigure

  configure
}


##
# decide what to do :P
##

case "$1" in
  install)
    install
    ;;
  reconfigure)
    reconfigure
    ;;
  remove)
    remove
    ;;
  *)
    # if no parameters are given print which are available
    echo "Usage: $0 {install|reconfigure|remove}"
    exit 1
    ;;
esac
