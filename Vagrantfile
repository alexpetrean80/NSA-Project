Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox"

  config.vm.box = "ubuntu/focal64"

  config.vm.network "public_network", 
    use_dhcp_assigned_default_route: true

  config.ssh.port = 2222

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
    vb.cpus = 2
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/playbook.yml"
  end
end 
