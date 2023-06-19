# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = "sqjian/jammy"
  
  # config.vm.box_version = "20230504.v1"

  # config.vm.provision "shell", name: "apt", path: "provisions/shell.sh"

  config.vm.box_check_update  = false
  config.vm.synced_folder ".", "/vagrant", disabled: false

  config.ssh.username = "root"
  config.ssh.password = "9527"

  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.56.6"

    $hosts = "
        set -eux -o pipefail
        sed -i '/master/d' /etc/hosts
        echo '192.168.56.6 master' >> /etc/hosts
        "
    master.vm.provision "shell", inline: $hosts

    master.vm.provider :virtualbox do |vb, override|
      vb.name = "master"
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--memory", "24576"]
      vb.customize ["modifyvm", :id, "--cpus", "12"]
    end
  end
end
