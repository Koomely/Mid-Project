## Creating and provisioning the Consul Servers and agents, and HA Proxy




### HA PROXY


resource "aws_instance" "haproxy" {

    ami = "${var.ami}"
	instance_type = "t2.micro"
	subnet_id = "${aws_subnet.public.id}"
	vpc_security_group_ids = ["${aws_security_group.mid_project_SG.id}"]
	key_name = "${var.key_name}"

    iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"


    connection {
        user = "ubuntu"
        private_key = "${file(var.private_key_path)}"
    }
     
    tags {
        Name = "public-haproxy"
        consul-cluster = "prod-cluster"
  }

    user_data = "${file("src/scripts/consul_prov.sh")}"

}

output "HA_Proxy" {
        value = "${aws_instance.haproxy.public_ip}"
    }

## Setting HA Proxy Config file


data "template_file" "haproxy_cfg" {
  template = "${file("src/templates/haproxy.tpl")}"
  vars = {
      k8s_minion_1 = "${aws_instance.k8s_minion_1.private_ip}"
      k8s_minion_2 = "${aws_instance.k8s_minion_2.private_ip}"
      consul_1 = "${aws_instance.consul_server.0.private_ip}"
      consul_2 = "${aws_instance.consul_server.1.private_ip}"
  }
}

#### Copying haproxy_cfg to Jenkins master to be copied later to HA Proxy server

resource "null_resource" "haproxy_cfg"{
        provisioner "file" {
            content = "${data.template_file.haproxy_cfg.rendered}"
            destination = "/home/ubuntu/haproxy.cfg"

            connection {
                host        = "${aws_instance.jenkins.public_ip}"
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.private_key_path)}"
            }

        }
}


### Consul Server and Agent provisioning

resource "aws_instance" "consul_server" {

    count = "${var.ha_count}"
    ami = "${var.ami}"
	instance_type = "t2.micro"
	subnet_id = "${aws_subnet.private.id}"
	vpc_security_group_ids = ["${aws_security_group.mid_project_SG.id}"]
	key_name = "${var.key_name}"

    iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"

    
    connection {
        user = "ubuntu"
        private_key = "${file(var.private_key_path)}"
    }
     
    tags {
        Name = "public-consul-${count.index}"
        consul-cluster = "prod-cluster"
  }

 user_data = "${file("src/scripts/consul_prov.sh")}"


}