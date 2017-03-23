#!/bin/bash
#
# Script to create a bootable disk image from an already created
# directory hierarchy (e.g. using debootstrap)
#
# Based on the instructions from this blog:
# http://www.olafdietsche.de/2016/03/24/debootstrap-bootable-image
#
# TODO: The script is installing grub (altering the bootstrap hierarchy) - is it needed?
# TODO: Receive parameters as command line arguments
# TODO: Avoid hardcoded values
# TODO: Remove change_password function

set -ex

######################################
# GLOBAL VARIABLES
######################################

# Warning! This is potentially destructive!
# If IMAGE_NAME points to a real device or partition, it will get overwritten
IMAGE_NAME="disk.img"
# Change this to the root folder where you have run 'debootstrap'
BOOTSTRAP_DIR="/home/ubuntu/base"
# Temporary dir to be used for mounting the image
MOUNT_DIR=`mktemp -d`
# Boot directory for the image
BOOT_DIR="${MOUNT_DIR}/boot"

######################################
# FUNCTIONS
######################################

create_empty_disk() {
    dd if=/dev/zero of=${IMAGE_NAME} bs=1024 count=1 seek=10239k
    parted -s disk.img -- mklabel msdos mkpart primary 1m 10g toggle 1 boot
}

mount_loop_device() {
    losetup -f ${IMAGE_NAME}
    partprobe /dev/loop0
    mkfs -t ext4 /dev/loop0p1
    mount /dev/loop0p1 ${MOUNT_DIR}
}

copy_data() {
    cp -r ${BOOTSTRAP_DIR}/* ${MOUNT_DIR}
}

install_grub() {
    grub-install --boot-directory=${BOOT_DIR} --modules=part_msdos /dev/loop0
    mount --bind /proc ${MOUNT_DIR}/proc
    mount --bind /dev ${MOUNT_DIR}/dev
    mount --bind /sys ${MOUNT_DIR}/sys
    chroot ${MOUNT_DIR} apt-get install -y grub-common
    chroot ${MOUNT_DIR} grub-mkconfig -o /boot/grub/grub.cfg
}

change_password() {
    chroot ${MOUNT_DIR} passwd
}

cleanup() {
    umount ${MOUNT_DIR}/sys
    umount ${MOUNT_DIR}/dev
    umount ${MOUNT_DIR}/proc
    umount ${MOUNT_DIR}
    losetup -d /dev/loop0
    rmdir ${MOUNT_DIR}
}

######################################
# EXECUTION SECTION
######################################

create_empty_disk
mount_loop_device
copy_data
install_grub
change_password
cleanup
