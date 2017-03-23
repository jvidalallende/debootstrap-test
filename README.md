# debootstrap-test

This is a setup for an automated system that generates disk images from
scratch. For complete isolation, a VM (based on Ubuntu 16.04) will be booted up,
then the target system (in this example based on Ubuntu 12.04) will be created,
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
        user@host ~/debootstrap-test> vagrant up

 3. SSH into the VM:

        user@host ~/debootstrap-test> vagrant ssh

 4. Notice that the prompt has changed. You are now *inside* the VM. In the HOME
    folder, you will see the script that will be used to create the disk image.
    Now, create a base root filesystem, based on Ubuntu 12.04 (precise)

        ubuntu@xenial ~> mkdir base
        ubuntu@xenial ~> sudo debootstrap --include=linux-image-generic precise base

 5. Now run the script

        ubuntu@xenial ~> sudo bash create-image.sh

 6. When the script finishes, you will see a file named *disk.img* in teh HOME
    folder. You can mv this file *outside* the VM, using the shared folder
    */vagrant*

        ubuntu@xenial ~> mv disk.img /vagrant/
