# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :haproxy => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.11.100', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :etcd => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.11.160', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :pg01 => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.11.151', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :pg02 => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.11.152', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :pg03 => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.11.153', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :zabbix01 => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.11.21', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },
  :zabbix02 => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.11.22', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "pgsql-net"},
            ]
  },

}

Vagrant.configure("2") do |config|

  config.vm.define "haproxy" do |c|
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2321, id: "ssh", host_ip: '127.0.0.1'
    c.vm.network "forwarded_port", adapter: 1, guest: 5000, host: 5000, host_ip: '127.0.0.1'
    c.vm.network "forwarded_port", adapter: 1, guest: 7000, host: 7000, host_ip: '127.0.0.1'
    #c.vm.network "public_network", adapter: 3, bridge: "wlp2s0"
  end
  config.vm.define "etcd" do |c|
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2421, id: "ssh", host_ip: '127.0.0.1'
  end
  config.vm.define "pg01" do |c|
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2521, id: "ssh", host_ip: '127.0.0.1'
  end
  config.vm.define "pg02" do |c|
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2621, id: "ssh", host_ip: '127.0.0.1'
  end
  config.vm.define "pg03" do |c|
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2721, id: "ssh", host_ip: '127.0.0.1'
  end
  config.vm.define "zabbix01" do |c|
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2821, id: "ssh", host_ip: '127.0.0.1'
    c.vm.network "public_network", adapter: 3, bridge: "wlp2s0"
  end
  config.vm.define "zabbix02" do |c|
    c.vm.network "forwarded_port", adapter: 1, guest: 22, host: 2921, id: "ssh", host_ip: '127.0.0.1'
    c.vm.network "public_network", adapter: 3, bridge: "wlp2s0"
  end

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.box_check_update = false
        box.vm.host_name = boxname.to_s

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
          ansible.playbook = "provisioning/01_tuning_OS.yml"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/02_etcd-haproxy.yml"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/03_pgsql-patroni.yml"
          ansible.become = "true"
        end
        box.vm.provision "ansible" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "provisioning/04_zabbix_pgsql.yml"
          ansible.become = "true"
        end
        #box.vm.provision "ansible" do |ansible|
        #  ansible.verbose = "v"
        #  ansible.playbook = "provisioning/05_create_database.yml"
        #  ansible.become = "true"
        #end

      end
  end
end
