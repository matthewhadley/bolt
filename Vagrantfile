# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "CentOS7vb"

  # ssh settings
  config.ssh.forward_agent = true

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8080
  # note to forward traffic to port 80 on osx use Vagrant Triggers:
  # https://github.com/emyl/vagrant-triggers
  # vagrant plugin install vagrant-triggers
  #
  #config.trigger.after [:provision, :up, :reload] do
  #  system('echo "
  #    rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 80 -> 127.0.0.1 port 8080
  #    rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 443 -> 127.0.0.1 port 4443
  #    " | sudo pfctl -ef - > /dev/null 2>&1; echo "==> Fowarding Ports: 80 -> 8080, 443 -> 4443 & Enabling pf"')
  #end

  # forwarding for ssh port
  # config.vm.network :forwarded_port, guest: 22, host: 2225, id: "ssh", auto_correct: true

  # hostname
  config.vm.hostname = "CentOS7vb.vagrant"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "./host", "/client"

  # add bolt mounts
  config.vm.synced_folder "~/dev/bash/bolt", "/usr/local/lib/bolt"
  config.vm.synced_folder "~/dev/bolted", "/etc/bolt"

  # add testing mount
  config.vm.synced_folder "/usr/local/Cellar/bats/0.4.0", "/usr/local/lib/bats"

  # add symlinks
  config.vm.provision "shell", inline: "ln -s /usr/local/lib/bolt/bin/bolt /usr/local/bin/bolt"
  config.vm.provision "shell", inline: "ln -s /usr/local/lib/bats/bin/bats /usr/local/bin/bats"

  # Virtualbox machine config
  config.vm.provider :virtualbox do |vb|
    # configure Vagrant VM to use Host DNS
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

    # vb.customize ["modifyvm", :id, "--memory", "2048"]
    # vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

end
