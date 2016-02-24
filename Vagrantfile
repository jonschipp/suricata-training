# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "trusty"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.provision "file", source: "suricata.conf", destination: "suricata.conf"
  config.vm.provision "shell", path:   "provision.sh"

  # config.vm.network "forwarded_port", guest: 80, host: 8080

  #config.vm.synced_folder "/Users/jonschipp/repos/islet", "/islet"

   config.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "islet-oisf"
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      vb.customize ["modifyvm", :id, "--cpus", 1]
   end

end
