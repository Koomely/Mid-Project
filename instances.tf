# INSTANCES #

variable "key_name" {}
variable "private_key_path" {}

variable "docker_pass" {}


#####################################
# Jenkins machine with Docker \ Ansible
#####################################

resource "aws_instance" "jenkins" {
	ami = "${var.ami}"
	instance_type = "t2.medium"
	subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
	vpc_security_group_ids = ["${aws_security_group.mid_project_SG.id}"]
	key_name = "${var.key_name}"

    connection {
      user = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }

    # Copying src folder
        provisioner "file" {
            source      = "src"
            destination = "~/src"

            connection {
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.private_key_path)}"
            }
        }

 # Copying Key
        provisioner "file" {
            source      = "${var.private_key_path}"
            destination = "~/.ssh/id_rsa"

            connection {
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.private_key_path)}"
            }
        }

 tags {
    Name = "mid-project-Jenkins"
  }

user_data = "${file("src/scripts/ansible_prov.sh")}"

depends_on = ["aws_instance.k8s_master"]


}



 output "Jenkins_IP" {
        value = "${aws_instance.jenkins.public_ip}"
    }

# Provionsing remote exec and waiting for Ansible to be installed

resource "null_resource" "provision"{
    provisioner "remote-exec" {
        
        inline = ["${file("src/scripts/jenkins_prov.sh")}"]

         connection {
                host        = "${aws_instance.jenkins.public_ip}"
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.private_key_path)}"
            }
    }

    depends_on = ["aws_instance.jenkins", "null_resource.k8s_prov"]

}





#####################################
## Kubernetes Instances and Output
#####################################

resource "aws_instance" "k8s_master" {
	ami = "${var.ami}"
	instance_type = "t2.medium"
	subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
	vpc_security_group_ids = ["${aws_security_group.mid_project_SG.id}"]
	key_name = "${var.key_name}"

    connection {
      user = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }

    iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
    user_data = "${file("src/scripts/consul_prov.sh")}"


 tags {
    Name = "mid-project-K8s-Master"
    consul-cluster = "prod-cluster"
  }

    depends_on = ["aws_instance.k8s_minion_1"]

}

#### Minions

resource "aws_instance" "k8s_minion_1" {
	ami = "${var.ami}"
	instance_type = "t2.micro"
	subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
	vpc_security_group_ids = ["${aws_security_group.mid_project_SG.id}"]
	key_name = "${var.key_name}"
    iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"

    connection {
      user = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
 tags {
    Name = "mid-project-K8s-Minion-1"
    consul-cluster = "prod-cluster"

  }
    user_data = "${file("src/scripts/consul_prov.sh")}"

    depends_on = ["aws_instance.k8s_minion_2"]

}

resource "aws_instance" "k8s_minion_2" {
	ami = "${var.ami}"
	instance_type = "t2.micro"
	subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
	vpc_security_group_ids = ["${aws_security_group.mid_project_SG.id}"]
	key_name = "${var.key_name}"
    iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"

    connection {
      user = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }

    user_data = "${file("src/scripts/consul_prov.sh")}"

tags {
    Name = "mid-project-K8s-Minion-2"
    consul-cluster = "prod-cluster"
  }
}






###########################
## Creating template files on Jenkins Master!
###########################

// Docker credentials file for Jenkins

data "template_file" "docker_pass" {
  template = "${file("src/templates/docker-cred.tpl")}"
  vars = {
      docker_pass = "${var.docker_pass}"
  }
}

resource "null_resource" "docker_pass"{

        provisioner "file" {
            content = "${data.template_file.docker_pass.rendered}"
            destination = "/home/ubuntu/src/Jenkins_init/docker-cred.xml"

            connection {
                host        = "${aws_instance.jenkins.public_ip}"
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.private_key_path)}"
            }

        }
}

// Ansible hosts

data "template_file" "ansible_hosts" {
  template = "${file("src/templates/ansible_hosts.tpl")}"
  vars = {
      k8s_master = "${aws_instance.k8s_master.private_ip}"
      k8s_minion_1 = "${aws_instance.k8s_minion_1.private_ip}"
      k8s_minion_2 = "${aws_instance.k8s_minion_2.private_ip}"
      consul_1 = "${aws_instance.consul_server.0.private_ip}"
      consul_2 = "${aws_instance.consul_server.1.private_ip}"
      haproxy = "${aws_instance.haproxy.private_ip}"
  }
}

resource "null_resource" "ansible_hosts"{

        provisioner "file" {
            content = "${data.template_file.ansible_hosts.rendered}"
            destination = "/home/ubuntu/src/yamls/ansible_hosts"

            connection {
                host        = "${aws_instance.jenkins.public_ip}"
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.private_key_path)}"
            }

        }
}


// vars.yml for K8s prov on JENKINS Master



data "template_file" "k8s_vars" {
  template = "${file("src/templates/vars.tpl")}"
  vars = {
      k8s_master = "${aws_instance.k8s_master.private_ip}"
      k8s_minion_1 = "${aws_instance.k8s_minion_1.private_ip}"
      k8s_minion_2 = "${aws_instance.k8s_minion_2.private_ip}"
  }
}

resource "null_resource" "k8s_vars"{

        provisioner "file" {
            content = "${data.template_file.k8s_vars.rendered}"
            destination = "/home/ubuntu/src/yamls/vars.yml"

            connection {
                host        = "${aws_instance.jenkins.public_ip}"
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.private_key_path)}"
            }

        }
}


resource "null_resource" "k8s_prov"{
    provisioner "remote-exec" {
        
        inline = ["${file("src/scripts/k8s_prov.sh")}"]

         connection {
                host        = "${aws_instance.jenkins.public_ip}"
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.private_key_path)}"
            }
    }

    depends_on = ["null_resource.k8s_vars", "null_resource.ansible_hosts", "aws_instance.k8s_minion_2"]

}


/*
resource "null_resource" "haproxy_copy"{
    provisioner "remote-exec" {
        
        inline = ["yes | sudo cp -rf /home/ubuntu/haproxy.cfg /etc/haproxy/haproxy.cfg", "sudo service haproxy reload"]

         connection {
                host        = "${aws_instance.jenkins.public_ip}"
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.private_key_path)}"
            }
    }

    depends_on = ["null_resource.haproxy_cfg"]

}
*/