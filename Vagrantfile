Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  nodes = {
    "cp1" => "192.168.56.11",
    "cp2" => "192.168.56.12",
    "cp3" => "192.168.56.13",
    "worker1" => "192.168.56.21"
  }

  nodes.each do |name, ip|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: ip
      node.vm.provider "virtualbox" do |vb|
        # recommended value 4Gi mem, 2 vcpu
        vb.memory = 1024
        vb.cpus = 1
      end

      node.vm.provision "shell", path: "scripts/base.sh"
      node.vm.provision "shell", path: "scripts/install-k8s.sh"
      if name.start_with?("cp")
        node.vm.provision "shell", path: "scripts/haproxy.sh"
      end
    end
  end
end
