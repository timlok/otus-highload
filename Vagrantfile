# -*- mode: ruby -*-
# vim: set ft=ruby :
home = ENV['HOME']

MACHINES = {
  :HLbalancer01 => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.51', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :HLbalancer02 => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.52', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :HLpgHaproxy => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.59', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :HLetcd => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.64', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :HLpg01 => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.65', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :HLpg02 => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.66', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :HLpg03 => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.67', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :HLzabbix01 => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.57', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :HLzabbix02 => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.58', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :HLclient => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.51.21.70', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
}

Vagrant.configure("2") do |config|

  config.vm.define "HLclient" do |c|
    c.vm.hostname = "hl-client"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2232, id: "ssh", host_ip: '127.0.0.1'
    c.vm.network "public_network", adapter: 3, bridge: "wlp2s0"
  end
  config.vm.define "HLbalancer01" do |c|
    c.vm.hostname = "hl-balancer01"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2231, id: "ssh", host_ip: '127.0.0.1'
    c.vm.network "public_network", adapter: 3, bridge: "wlp2s0"
  end
  config.vm.define "HLbalancer02" do |c|
    c.vm.hostname = "hl-balancer02"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2241, id: "ssh", host_ip: '127.0.0.1'
    c.vm.network "public_network", adapter: 3, bridge: "wlp2s0"
  end
  config.vm.define "HLpgHaproxy" do |c|
    c.vm.hostname = "hl-pg-haproxy"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2321, id: "ssh", host_ip: '127.0.0.1'
    c.vm.network "forwarded_port", adapter: 1, guest: 5000, host: 5000, host_ip: '127.0.0.1'
    c.vm.network "forwarded_port", adapter: 1, guest: 7000, host: 7000, host_ip: '127.0.0.1'
    #c.vm.network "public_network", adapter: 3, bridge: "wlp2s0"
  end
  config.vm.define "HLetcd" do |c|
    c.vm.hostname = "hl-etcd"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2421, id: "ssh", host_ip: '127.0.0.1'
  end
  config.vm.define "HLpg01" do |c|
    c.vm.hostname = "hl-pg01"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2521, id: "ssh", host_ip: '127.0.0.1'
  end
  config.vm.define "HLpg02" do |c|
    c.vm.hostname = "hl-pg02"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2621, id: "ssh", host_ip: '127.0.0.1'
  end
  config.vm.define "HLpg03" do |c|
    c.vm.hostname = "hl-pg03"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2721, id: "ssh", host_ip: '127.0.0.1'
  end
  config.vm.define "HLzabbix02" do |c|
    c.vm.hostname = "hl-zabbix02"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2921, id: "ssh", host_ip: '127.0.0.1'
    c.vm.network "public_network", adapter: 3, bridge: "wlp2s0"
  end
  config.vm.define "HLzabbix01" do |c|
    c.vm.hostname = "hl-zabbix01"
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2821, id: "ssh", host_ip: '127.0.0.1'
    c.vm.network "public_network", adapter: 3, bridge: "wlp2s0"
  end

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.box_check_update = false
        #box.vm.host_name = boxname.to_s

        #BUGGY!!!
        #box.vm.synced_folder "for_mysql_dump/", "/tmp/for_mysql_dump", type: "rsync"
        #box.vbguest.auto_update = true
        #box.vbguest.auto_update = false

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end

        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end

        box.vm.provider "virtualbox" do |v|
          v.customize ["modifyvm", :id, "--audio", "none"]
          #v.memory = "1024"
          v.memory = "512"
          v.cpus = "1"
        end

        box.vm.provision "shell", inline: <<-SHELL
                mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
                sed -i 's/^PasswordAuthentication no/#PasswordAuthentication no/g' /etc/ssh/sshd_config
                sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
                systemctl restart sshd
        SHELL

        box.vm.provision "ansible" do |ansible|
          #ansible.verbose = "v"
          ansible.playbook = "provisioning/HA/01_tuning_OS.yml"
          ansible.inventory_path = "provisioning/HA/hosts"
          ansible.inventory_path = "provisioning/HA/hosts_vagrant"
          ansible.extra_vars = "provisioning/HA/variables"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/HA/02_hl-client_docker-yandextank.yml"
          ansible.inventory_path = "provisioning/HA/hosts"
          ansible.inventory_path = "provisioning/HA/hosts_vagrant"
          ansible.extra_vars = "provisioning/HA/variables"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/HA/03_keepalived-haproxy.yml"
          ansible.inventory_path = "provisioning/HA/hosts"
          ansible.inventory_path = "provisioning/HA/hosts_vagrant"
          ansible.extra_vars = "provisioning/HA/variables"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/HA/04_etcd-haproxy.yml"
          ansible.inventory_path = "provisioning/HA/hosts"
          ansible.inventory_path = "provisioning/HA/hosts_vagrant"
          ansible.extra_vars = "provisioning/HA/variables"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/HA/05_pgsql-patroni-server.yml"
          ansible.inventory_path = "provisioning/HA/hosts"
          ansible.inventory_path = "provisioning/HA/hosts_vagrant"
          ansible.extra_vars = "provisioning/HA/variables"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/HA/06_pgsql-client.yml"
          ansible.inventory_path = "provisioning/HA/hosts"
          ansible.inventory_path = "provisioning/HA/hosts_vagrant"
          ansible.extra_vars = "provisioning/HA/variables"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/HA/07_zabbix.yml"
          ansible.inventory_path = "provisioning/HA/hosts"
          ansible.inventory_path = "provisioning/HA/hosts_vagrant"
          ansible.extra_vars = "provisioning/HA/variables"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/HA/08_pacemaker.yml"
          ansible.inventory_path = "provisioning/HA/hosts"
          ansible.inventory_path = "provisioning/HA/hosts_vagrant"
          ansible.extra_vars = "provisioning/HA/variables"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/HA/09_mamonsu.yml"
          ansible.inventory_path = "provisioning/HA/hosts"
          ansible.inventory_path = "provisioning/HA/hosts_vagrant"
          ansible.extra_vars = "provisioning/HA/variables"
          ansible.become = "true"
        end

      end
  end
end
