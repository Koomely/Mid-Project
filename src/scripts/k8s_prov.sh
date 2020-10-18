while [ ! -f /home/ubuntu/Done ] ; do echo 'Waiting on User Data and YAML files...'; sleep 3; done;
sleep 5;



### Setting K8s devices

cd /home/ubuntu/src/yamls
ansible-playbook -i ansible_hosts install-docker.yml
ansible-playbook -i ansible_hosts k8s-common.yml
ansible-playbook -i ansible_hosts k8s-master.yml
ansible-playbook -i ansible_hosts k8s-minion.yml

# setting HA Proxy

ansible-playbook -i ansible_hosts haproxy.yaml




