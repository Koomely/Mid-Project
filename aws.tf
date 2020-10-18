variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}


# getting data for availability zones

data "aws_availability_zones" "available" {}

# create VPC

resource "aws_vpc" "mid_project_vpc" {
  cidr_block           = "${var.cidr_block}"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "mid-project-VPC"
  }
}


# Creating Security group 

resource "aws_security_group" "mid_project_SG" {
  name        = "mid-project-SG"
  description = "Allow ssh inbound traffic from world + all ports internal traffic"
  vpc_id = "${aws_vpc.mid_project_vpc.id}"

  tags {
    Name = "mid-project-SG"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }

  ingress {
    from_port   = 5050
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Port 5050:30036 for the Docker app from the world"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Port 8000 for HAProxy stats from the world"
  }

ingress {
    from_port   = 8050
    to_port     = 8050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Port 8050:8500 for Consul Servers from the world"
  }


  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Jenkins port from the world"
  }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }
 
}



# setup internet Gateway and NAT Gateway


resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.mid_project_vpc.id}"

  tags {
    Name = "mid-project-main-gw"
  }
}

resource "aws_eip" "nat" {
  count      = "${var.count}"
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]

  tags {
    Name = "mid-project-EIP-${element(aws_subnet.public.*.availability_zone, count.index)}"
  }
}

resource "aws_nat_gateway" "gw" {
  count         = "${var.count}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name = "mid-project-NAT-${element(aws_subnet.public.*.availability_zone, count.index)}"
  }

  depends_on = ["aws_eip.nat"]
}


// ELB for the K8s minions
/*
resource "aws_elb" "k8s-lb" {
 name = "project-k8s-lb"

 security_groups = [
   "${aws_security_group.mid_project_SG.id}"
 ]

 subnets = ["${aws_subnet.public.id}"]

 listener {
   instance_port     = 30036
   instance_protocol = "TCP"
   lb_port           = 5050
   lb_protocol       = "TCP"
 }

 health_check {
   healthy_threshold   = 2
   unhealthy_threshold = 2
   timeout             = 3
   target              = "HTTP:30036/"
   interval            = 30
 }
instances = ["${aws_instance.k8s_minion_1.id}" , "${aws_instance.k8s_minion_2.id}"]
 }

 output "ELB_DNS" {
        value = "${aws_elb.k8s-lb.dns_name}"
    }

*/