# debootstrap-test

This is a setup for an automated system that generates disk images from
scratch. For complete isolation, a VM (based on Ubuntu 16.04) will be booted up,
then the target system (in this example based on Ubuntu 14.04) will be created,
and copied to a shared folder, so that it is accessible from outside the VM.

## Dependencies

This environment should be easily reproducible in any Windows/Mac/GNU Linux
host. All that you need are these tools:

 - **[Git](https://git-scm.com/downloads)**: To clone this repository
 - **[Vagrant](https://www.vagrantup.com/downloads.html)**: To boot the host Virtual Machine
 - **[Virtualbox](https://www.virtualbox.org/wiki/Downloads)**: As a Vagrant provider

Vagrant allows different [providers](https://www.vagrantup.com/docs/providers/)
to be used, although this has only be (slightly) tested with VirtualBox.

## How to get this running

Once you have installed everything in your host machine, you can just follow
these steps:

 1. Clone this repository

        user@host ~> git clone https://github.com/jvidalallende/debootstrap-test

 2. Get into the repository folder, and use vagrant to create the VM where
    will create disk images. This will take some time the first time it is run,
    as it will download Ubuntu 16.04 base box. It will take shorter time next
    times.

        user@host ~> cd debootstrap-test
        user@host ~/debootstrap-test> vagrant up && vagrant destroy -f

 3. You are done! You should see a *qcow2* file. That is the disk file that you
    can use for your VM.


## Booting up the disk image

The easiest way to test the image just created is using [QEMU](http://www.qemu-project.org/).
After installing it, you can boot the VM with this command:

    user@host ~/debootstrap-test> qemu-system-x86_64 -machine ubuntu,accel=kvm -drive format=qcow2,file=disk.qcow2 -m 512M -device virtio-net

Another alternative could be using VirtualBox, although you might need to convert
the disk image to a format that can be handled by virtualbox:

    user@host ~/debootstrap-test> qemu-img convert -f qcow2 -O vmdk disk.qcow2 disk.vmdk

Now create a VM and assign *disk.vmdk* as its primary hard disk drive.
