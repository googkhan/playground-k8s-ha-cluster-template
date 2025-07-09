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
      node.vm.network "private_network", ip: details[:ip]
      node.vm.provider "virtualbox" do |vb|
        # recommended value 4Gi mem, 2 vcpu
        vb.memory = 2048
        vb.cpus = 2
      end

      # vagrant stages:

      # stage 1, base os and container runtime, all nodes
      # containerd kubelet kubeadm kubectl
      node.vm.provision "shell", path: "scripts/base.sh"
      node.vm.provision "shell", path: "scripts/install-k8s.sh"

      # stage 2, haproxy and keepalived
      # control planes only
      if name.start_with?("cp")
        node.vm.provision "shell", path: "scripts/haproxy.sh", args: K8S_IP
        node.vm.provision "shell", path: "scripts/keepalived.sh", args: [K8S_IP, details[:ip]]
      end

      # stage 3, k8s cluster init-join

      # 3.1 init cluster, on first cp, run once!
      if name == "cp1"
        node.vm.provision "shell",
          path: "scripts/init-control-plane.sh",
          args: K8S_VIP,
          run: "once"
      end

      # 3.2 post cluster init, run once!
      if name == "cp1"
        node.vm.provision "shell",
          path: "scripts/post-init.sh",
          run: "once"
      end

      # 3.3 join other cp, run once!
      if name.starts_with?("cp") && name != "cp1"
        node.vm.provision "shell",
          path: "scripts/join-control-plane.sh",
          args: K8S_VIP,
          run: "once"
      end
      
      # 3.4 join worker, run once!
      if name.starts_with?("worker")
        node.vm.provision "shell",
          path: "scripts/join-worker.sh",
          args: K8S_VIP,
          run: "once"
      end

    end
  end
end
