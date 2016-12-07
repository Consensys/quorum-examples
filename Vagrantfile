Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, path: "vagrant/bootstrap.sh"
  config.vm.network "forwarded_port", guest: 22000, host: 22000
  config.vm.network "forwarded_port", guest: 22001, host: 22001
  config.vm.network "forwarded_port", guest: 22002, host: 22002
  config.vm.network "forwarded_port", guest: 22003, host: 22003
  config.vm.network "forwarded_port", guest: 22004, host: 22004
  config.vm.network "forwarded_port", guest: 22005, host: 22005
  config.vm.network "forwarded_port", guest: 22006, host: 22006
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
  end
end
