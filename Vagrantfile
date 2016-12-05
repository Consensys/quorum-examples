Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, path: "vagrant/bootstrap.sh"
  config.vm.network :private_network, ip: "192.168.44.9"
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
  end
end
