# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.define "nodea" do |nodea|
        nodea.vm.box = "bento/centos-7.4"
        nodea.vm.provider "virtualbox" do |v|
          v.name = "nodea"
          v.customize ["modifyvm", :id, "--memory", "2048"]
        end
        nodea.vm.network :private_network, ip: "192.168.92.11"
        nodea.vm.hostname = "nodea"
        nodea.vm.provision :shell, path: "scripts/setup-node.sh"
    end
    
    config.vm.define "nodeb" do |nodeb|
        nodeb.vm.box = "bento/centos-7.4"
        nodeb.vm.provider "virtualbox" do |v|
          v.name = "nodeb"
          v.customize ["modifyvm", :id, "--memory", "2048"]
        end
        nodeb.vm.network :private_network, ip: "192.168.92.12"
        nodeb.vm.hostname = "nodeb"
        nodeb.vm.provision :shell, path:  "scripts/setup-node.sh"
    end
    
    config.vm.define "nodemasterx" do |nodemasterx|
        nodemasterx.vm.box = "bento/centos-7.4"
        nodemasterx.vm.provider "virtualbox" do |v|
          v.name = "nodemasterx"
          v.customize ["modifyvm", :id, "--memory", "1024"]
        end
        nodemasterx.vm.network :private_network, ip: "192.168.92.10"
        nodemasterx.vm.hostname = "nodemasterx"
        nodemasterx.vm.provision :shell, path: "scripts/setup-nodemaster.sh"
    end
end
