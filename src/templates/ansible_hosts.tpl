[k8s_master]
k8s_master ansible_host=${k8s_master} ansible_user=ubuntu ansible_connection=ssh

[k8s_minions]
k8s_minion_1 ansible_host=${k8s_minion_1} ansible_user=ubuntu ansible_connection=ssh
k8s_minion_2 ansible_host=${k8s_minion_2} ansible_user=ubuntu ansible_connection=ssh


[consul]
consul_1 ansible_host=${consul_1} ansible_user=ubuntu ansible_connection=ssh
consul_2 ansible_host=${consul_2} ansible_user=ubuntu ansible_connection=ssh

[haproxy]
haproxy ansible_host=${haproxy} ansible_user=ubuntu ansible_connection=ssh

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'