Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_version = ">= 20190909.1.0"
  # config.disksize.size = "30GB"
  config.vm.provision :shell, path: "vagrant/bootstrap.sh"

  # Quorum RPC node ports
  config.vm.network "forwarded_port", guest: 22000, host: 22000
  config.vm.network "forwarded_port", guest: 22001, host: 22001
  config.vm.network "forwarded_port", guest: 22002, host: 22002
  config.vm.network "forwarded_port", guest: 22003, host: 22003
  config.vm.network "forwarded_port", guest: 22004, host: 22004
  config.vm.network "forwarded_port", guest: 22005, host: 22005
  config.vm.network "forwarded_port", guest: 22006, host: 22006

  # Tessera third-party API ports
  config.vm.network "forwarded_port", guest: 9081, host: 9081
  config.vm.network "forwarded_port", guest: 9082, host: 9082
  config.vm.network "forwarded_port", guest: 9083, host: 9083
  config.vm.network "forwarded_port", guest: 9084, host: 9084
  config.vm.network "forwarded_port", guest: 9085, host: 9085
  config.vm.network "forwarded_port", guest: 9086, host: 9086
  config.vm.network "forwarded_port", guest: 9087, host: 9087

  # Cakeshop
  config.vm.network "forwarded_port", guest: 8999, host: 8999

  config.vm.provider "virtualbox" do |v|
    v.memory = 6144
  end
end
