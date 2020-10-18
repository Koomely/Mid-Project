variable "region" {
  description = "AWS region for VMs"
  default = "us-east-1"
}

variable "ami" {
  description = "ami to use"
  default = "ami-0565af6e282977273"
}

## ami-0ac019f4fcb7cb7e6

variable "cidr_block" {
  description = "Main CIDR Block for our VPC"
  default = "10.10.0.0/16"
}

variable "count" {
  default = 1
}

variable "ha_count" {
  default = 2
}