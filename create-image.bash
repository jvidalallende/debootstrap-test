#!/bin/bash
#
# Script to create a bootable disk image from an already created
# directory hierarchy (e.g. using debootstrap)
#
# Based on the instructions from this blog:
# http://www.olafdietsche.de/2016/03/24/debootstrap-bootable-image
#
# TODO: Receive parameters as command line arguments
# TODO: Avoid hardcoded values

set -uex

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
# debootstrap release (e.g. precise, trusty, xenial...)
RELEASE="trusty"
# Source /etc/fstab file
SOURCE_FSTAB="/tmp/fstab"
# Source /etc/network/interfaces file
SOURCE_INTERFACES="/tmp/interfaces"

######################################
# FUNCTIONS
######################################

create_debootstrap() {
    mkdir ${BOOTSTRAP_DIR}
    debootstrap --include=linux-image-generic ${RELEASE} ${BOOTSTRAP_DIR}
}

create_empty_disk() {
    dd if=/dev/zero of=${IMAGE_NAME} bs=1024 count=1 seek=2047k
    parted -s disk.img -- mklabel msdos mkpart primary 1m 2g toggle 1 boot
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

install_packages() {
    chroot ${MOUNT_DIR} apt-get install -y \
        python2.7 \
        tcpdump \
        cloud-init \
        wget \
        grub2-common \
        openssh-server \
        openssh-client
}

setup_grub() {
    # Boot directly into the OS
    chroot ${MOUNT_DIR} bash -c "echo GRUB_TIMEOUT=0 > /etc/default/grub"
    chroot ${MOUNT_DIR} bash -c "echo GRUB_HIDDEN_TIMEOUT=0 > /etc/default/grub"
    # Disable other OS detection. Also avoids timeout adjustment by os-prober
    chmod -x ${MOUNT_DIR}/etc/grub.d/30_os-prober 
    mount --bind /proc ${MOUNT_DIR}/proc
    mount --bind /dev ${MOUNT_DIR}/dev
    mount --bind /sys ${MOUNT_DIR}/sys
    grub-install --boot-directory=${BOOT_DIR} --skip-fs-probe --modules=part_msdos /dev/loop0
    chroot ${MOUNT_DIR} grub-mkconfig -o /boot/grub/grub.cfg
    umount ${MOUNT_DIR}/sys
    umount ${MOUNT_DIR}/dev
    umount ${MOUNT_DIR}/proc
}

get_vxlan_tool() {
    chroot ${MOUNT_DIR} wget -O /root/vxlan_tool.py \
        https://raw.githubusercontent.com/opendaylight/sfc/master/sfc-test/nsh-tools/vxlan_tool.py
    chroot ${MOUNT_DIR} chmod +x /root/vxlan_tool.py
}

change_password() {
    chroot ${MOUNT_DIR} bash -c "echo 'root:opnfv' | chpasswd"
}

modify_host() {
    chroot ${MOUNT_DIR} bash -c "echo opnfv-sfc > /etc/hostname"
    cp ${SOURCE_FSTAB} ${MOUNT_DIR}/etc/fstab
    chmod 664 ${MOUNT_DIR}/etc/fstab
    cp ${SOURCE_INTERFACES} ${MOUNT_DIR}/etc/network/interfaces
    chmod 644 ${MOUNT_DIR}/etc/network/interfaces
}

cleanup() {
    umount ${MOUNT_DIR}
    losetup -d /dev/loop0
    rmdir ${MOUNT_DIR}
}

prepare_final_image() {
    qemu-img convert -f raw -O qcow2 disk.img disk.qcow2 
    virt-sparsify --compress disk.qcow2 /vagrant/sf_nsh_euphrates_candidate.qcow2
}

######################################
# EXECUTION SECTION
######################################

create_debootstrap
create_empty_disk
mount_loop_device
copy_data
install_packages
setup_grub
get_vxlan_tool
change_password
modify_host
cleanup
prepare_final_image
