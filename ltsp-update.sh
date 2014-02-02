#!/bin/sh

CHROOT_DIR=/opt/ltsp/amd64

sudo chroot $CHROOT_DIR mount -t proc /proc /proc 
sudo chroot $CHROOT_DIR apt-get update
sudo chroot $CHROOT_DIR env LTSP_HANDLE_DAEMONS=false apt-get dist-upgrade
sudo umount /opt/ltsp/amd64/proc
sudo ltsp-update-kernels 
sudo ltsp-update-image
