variable "dns1" {
  type    = string
  default = "10.175.128.10"
}

variable "dns2" {
  type    = string
  default = "10.175.129.10"
}

variable "vpn_gateway_id" {
  type    = string
  default = "vgw-0beafaabfc03b79a1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.175.128.0/20"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "tags_default" {
  type = map(any)
  default = {
    "Automation" = "yes"
  }
}


variable "aws_ec2_settings" {
  type = map(string)
  default = {
    ami                         = "ami-090f10efc254eaf55"
    key_name                    = "admin"
    associate_public_ip_address = "false"
    delete_on_termination       = "true"
    volume_type                 = "gp2"
    associate_public_ip_address = "false"
    create_before_destroy       = "true"
  }
}
