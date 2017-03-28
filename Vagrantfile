# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Base box is Ubuntu 16.04 Xenial Xerus
  config.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/xenial64"
  config.vm.box = "ubuntu/xenial64"

  config.vm.provider :virtualbox do |vb|
    vb.name = "debootstrap-test"
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.provision "shell", path: "bootstrap.bash", privileged: false
  config.vm.provision "file", source: "image-files/fstab", destination: "/tmp/fstab"
  config.vm.provision "file", source: "image-files/interfaces", destination: "/tmp/interfaces"
  config.vm.provision "file", source: "create-image.bash", destination: "~/create-image.bash"

  # This is not provisioning, but it is very convenient to run the script
  # if everything goes fine, doing "vagrant up && vagrant destroy -f" will
  # work as a process that produces an image
  # NOTE: the script is run as root!
  config.vm.provision "shell", inline: "bash create-image.bash", privileged: true
end
