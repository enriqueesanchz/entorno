# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :
# Box / OS
VAGRANT_BOX = 'bento/debian-10'
# Memorable name for your
VM_NAME = 'cloud'
# VM User — 'vagrant' by default
VM_USER = 'sigma'
# Host folder to sync
HOST_PATH = '.'
# Where to sync to on Guest — 'vagrant' is the default user name
GUEST_PATH = '/home/' + VM_USER
# # VM Port — uncomment this to use NAT instead of DHCP
# VM_PORT = 8080
Vagrant.configure(2) do |config|
  # Vagrant box from Hashicorp
  config.vm.box = VAGRANT_BOX
  # Actual machine name
  config.vm.hostname = VM_NAME
  # Set VM name in Virtualbox
  config.vm.provider "virtualbox" do |v|
    v.name = VM_NAME
    v.memory = 2048
  end
  config.vm.network "private_network", type: "dhcp"
  #config.vm.network "public_network", bridge: "Intel(R) Ethernet Connection (7) I219-V"
  #config.vm.network "forwarded_port", guest: 49001, host: 49001
  # # Port forwarding — uncomment this to use NAT instead of DHCP
  # config.vm.network "forwarded_port", guest: 80, host: VM_PORT
  # Sync folder
  config.vm.synced_folder HOST_PATH, GUEST_PATH
  if Vagrant.has_plugin?("vagrant-vbguest") then
        config.vbguest.auto_update = false
  end
  # Disable default Vagrant folder, use a unique path per project
  config.vm.synced_folder '.', '/home/'+VM_USER+'', disabled: true
  # Install sigma
  config.vm.provision "shell", path: "initwildfly.sh"
end


