#! /bin/bash
apt update
apt install bc stress -y
git clone https://github.com/hashicorp/terraform-aws-consul.git
terraform-aws-consul/modules/install-consul/install-consul --version 0.9.1

#echo $(hostname) > /home/ubuntu/hostname
#cd /home/ubuntu/src/yamls

# Install common consul config and upstart job

#ansible-playbook -i ansible_hosts consul_common.yaml



# Configure HA Proxy consul server

#ansible-playbook -i ansible_hosts consul_lb.yaml


# Configure Consul Servers

#ansible-playbook -i ansible_hosts consul_servers.yaml

# Configure K8s minions

#ansible-playbook -i ansible_hosts consul_k8s.yaml

