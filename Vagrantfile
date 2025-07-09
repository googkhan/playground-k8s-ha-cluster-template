Vagrant.configure("2") do |config|
  # vagrant box image ubuntu 22.04 lts
  config.vm.box = "ubuntu/jammy64"

  # hostnames, roles and ips
  nodes = {
    "cp1" => { ip: "192.168.56.11", role: "control-plane-init" },
    "cp2" => { ip: "192.168.56.12", role: "control-plane-join" },
    "cp3" => { ip: "192.168.56.13", role: "control-plane-join" },
    "worker1" => { ip: "192.168.56.21", role: "worker" }
  }

  # virtual ip for haproxy, provided by keepalived
  # for k8s api server high availability
  K8S_VIP = "192.168.56.10"

  # loop through each node for conf
  nodes.each do |name, ip|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: ip
      node.vm.provider "virtualbox" do |vb|
        # recommended value 4Gi mem, 2 vcpu
        vb.memory = 2048
        vb.cpus = 2
      end

      node.vm.provision "shell", path: "scripts/base.sh"
      node.vm.provision "shell", path: "scripts/install-k8s.sh"
      if name.start_with?("cp")
        node.vm.provision "shell", path: "scripts/haproxy.sh"
      end
    end
  end
end
