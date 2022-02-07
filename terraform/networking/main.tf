# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "subnet-private-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.175.128.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1a"
  tags = merge(var.tags_default, {
    "Name" = "subnet-private-1a"
  })
  lifecycle {
    ignore_changes = [tags, ]
  }
}

resource "aws_subnet" "subnet-private-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.175.129.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1b"
  tags = merge(var.tags_default, {
    "Name" = "subnet-private-1b"
  })
  lifecycle {
    ignore_changes = [tags, ]
  }
}

resource "aws_subnet" "subnet-private-1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.175.130.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1c"
  tags = merge(var.tags_default, {
    "Name" = "subnet-private-1c"
  })
  lifecycle {
    ignore_changes = [tags, ]
  }
}

resource "aws_subnet" "subnet-public-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.175.131.240/28"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1a"
  tags = merge(var.tags_default, {
    "Name" = "subnet-public-1a"
  })
  lifecycle {
    ignore_changes = [tags, ]
  }
}

resource "aws_subnet" "subnet-public-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.175.131.224/28"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1b"
  tags = merge(var.tags_default, {
    "Name" = "subnet-public-1a"
  })
  lifecycle {
    ignore_changes = [tags, ]
  }
}

resource "aws_subnet" "subnet-public-1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.175.131.208/28"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1c"
  tags = merge(var.tags_default, {
    "Name" = "subnet-public-1c"
  })
  lifecycle {
    ignore_changes = [tags, ]
  }
}

# EKS subnets
resource "aws_subnet" "subnet-k8s-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.175.132.0/22"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1a"
  tags = merge(var.tags_default, {
    "Name"                                            = "subnet-k8s-1a"
    "kubernetes.io/cluster/eks-ss-rampup-task" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
  })
  lifecycle {
    ignore_changes = [tags, ]
  }
}

resource "aws_subnet" "subnet-k8s-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.175.136.0/22"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1b"
  tags = merge(var.tags_default, {
    "Name"                                            = "subnet-k8s-1b"
    "kubernetes.io/cluster/eks-ss-rampup-task" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
  })
  lifecycle {
    ignore_changes = [tags, ]
  }
}

resource "aws_subnet" "subnet-k8s-1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.175.140.0/22"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1c"
  tags = merge(var.tags_default, {
    "Name"                                            = "subnet-k8s-1c"
    "kubernetes.io/cluster/eks-ss-rampup-task" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
  })
  lifecycle {
    ignore_changes = [tags, ]
  }
}



# Nat gateway related
resource "aws_eip" "eip-nat" {
  vpc = true
  tags = merge(var.tags_default, {
    "Name" = "dev-eip-nat"
  })
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_subnet.subnet-public-1a.id
  tags = merge(var.tags_default, {
    "Name" = "dev-nat-gw"
  })
}

resource "aws_route" "route-internet-access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
}

# All related to route table rt-public
resource "aws_internet_gateway" "igw-public" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags_default, {
    "Name" = "dev-igw"
  })
}

resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-public.id
  }
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = "tgw-0dd828f27a928d408"
  }
  route {
    cidr_block         = "172.16.0.0/12"
    transit_gateway_id = "tgw-0dd828f27a928d408"
  }
  route {
    cidr_block         = "192.168.0.0/16"
    transit_gateway_id = "tgw-0dd828f27a928d408"
  }

  tags = merge(var.tags_default, {
    "Name" = "dev-rt-public"
  })
}

resource "aws_vpc_dhcp_options" "main" {
  #  domain_name         = var.domain
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = aws_vpc.main
}

output "all_worker_mgmt" {
  description = "Private subnet id"
  value       = aws_security_group.all_worker_mgmt.id
}

resource "aws_security_group_rule" "all_worker_mgmt_ingress_rule1" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.all_worker_mgmt.id
  description       = "eks interconnect"
}
