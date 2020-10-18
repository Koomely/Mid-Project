#! /bin/bash
apt update
apt-add-repository ppa:ansible/ansible
apt update
apt install software-properties-common -y
apt install python -y
apt install ansible -y
apt install openjdk-8-jre -y
apt install bc stress -y
chmod 666 /home/ubuntu/src/scripts/*
chmod 666 /home/ubuntu/src/yamls/*
chmod 777 /home/ubuntu/src/yamls/consul_provision
chmod -R 666 /home/ubuntu/src/Jenkins_init/*
chmod 400 /home/ubuntu/.ssh/id_rsa
ansible-playbook -l localhost /home/ubuntu/src/yamls/install-docker.yml
usermod -aG docker ubuntu
gpasswd -a ubuntu docker
# Installing GOSS for testing
curl -fsSL https://goss.rocks/install | sudo sh
ansible-playbook -l localhost /home/ubuntu/src/yamls/jenkins_init.yml
touch /home/ubuntu/Done

