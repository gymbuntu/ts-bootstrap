#!/bin/bash
#
# ltsp-bootstrap install a ltsp server with some dependencies
# mainly it enables ldap authentication using PAM-LDAP

# Ask for the administrator password upfront
sudo -v

BOOT="$(pwd)"

set -e

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

configure() {
  info 'Configuring LTSP-Server'

  # copy the client config
  CLIENT_CONF="$BOOT/ltsp-build-client.conf"
  CLIENT_CONF_TO="/etc/ltsp/ltsp-build-client.conf"
  if [ -e "$CLIENT_CONF" ]
  then
    sudo cp $CLIENT_CONF $CLIENT_CONF_TO
    success "Copied $(basename $CLIENT_CONF) to $CLIENT_CONF_TO"
  fi

  # copy the image config
  IMAGE_CONF="$BOOT/ltsp-update-image.conf"
  IMAGE_CONF_TO="/etc/ltsp/ltsp-update-image.conf"
  if [ -e "$IMAGE_CONF" ]
  then
    sudo cp $IMAGE_CONF $IMAGE_CONF_TO
    success "Copied $(basename $IMAGE_CONF) to $IMAGE_CONF_TO"
  fi
}


install() {
  info 'Installing ltsp-server ...'

  sudo apt-get install -y -q ltsp-server openssh-server >/dev/null
  success 'Installed ltsp-server'

  configure
}

remove() {
  info 'Removing (purging) ltsp-server ...'

  sudo apt-get purge -y -q ltsp-server >/dev/null
  success 'Removed ltsp-server'
}

reconfigure() {
  info 'Reconfiguring ltsp-server ...'
  configure
}

# determine the correct arch
client-conf() {
  # default base is /opt/ltsp
  BASE="/opt/ltsp"
  # the default arch for the ltsp chroot is like the machine arch
  # it might be overriden by the build-client.conf
  if [ "$(uname -m)" == "x86_64" ]
  then
    ARCH="amd64"
  else
    ARCH="i386"
  fi

  CONF="/etc/ltsp-build-client.conf"
  # check if the client configuration exists
  [ -e "$CONF" ] && source $CONF

  export BASE="$BASE"
  export ARCH="$ARCH"
}

build-client() {
  info 'Building LTSP Client Image ...'

  client-conf

  if [ -d "$BASE/$ARCH" ]
  then
    sudo rm -rf "$BASE/$ARCH"
    success "Had to remove old LTSP Client Image $BASE/$ARCH"
  fi

  info 'Building LTSP Client Image now ...'
  sudo ltsp-build-client --arch $ARCH >/dev/null

  success 'Built a new LTSP Client Image'
}

update-image() {
  info 'Updating LTSP Client Image ...'

  client-conf

  sudo ltsp-update-image --arch $ARCH >/dev/null

  success 'Created an updated LTSP Client Image'
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
  build-client)
    build-client
    ;;
  update-image)
    update-image
    ;;
  *)
    # if no parameters are given print which are available
    echo "Usage: $0 {install|reconfigure|remove|build-client|update-image}"
    exit 1
    ;;
esac
