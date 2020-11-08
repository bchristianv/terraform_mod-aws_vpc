# AWS VPC

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  tags = {
    "Name" = "VPC - ${var.name}"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each                = var.az_public_subnets
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, each.value.sbits, each.value.net)
  availability_zone       = "${var.aws_region}${each.key}"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Public Subnet ${var.aws_region}${each.key} - VPC ${var.name}"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = length(var.az_public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "IGW - VPC ${var.name}"
  }
}

resource "aws_route_table" "public_rt" {
  count  = length(var.az_public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "Public subnet routes - VPC ${var.name}"
  }
}

resource "aws_route_table_association" "public_rt_assocs" {
  count          = length(var.az_public_subnets)
  subnet_id      = values(aws_subnet.public_subnets)[count.index].id
  route_table_id = aws_route_table.public_rt[0].id
}

resource "aws_route" "public_default_route" {
  count                  = length(var.az_public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
  depends_on             = [aws_route_table.public_rt]
}

resource "aws_subnet" "private_subnets" {
  for_each                = var.az_private_subnets
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, each.value.sbits, each.value.net)
  availability_zone       = "${var.aws_region}${each.key}"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Private Subnet ${var.aws_region}${each.key} - VPC ${var.name}"
  }
}

resource "aws_eip" "nat_gw_eips" {
  count      = length(var.az_public_subnets) > 0 ? length(var.az_private_subnets) : 0
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gws" {
  count         = length(var.az_public_subnets) > 0 ? length(var.az_private_subnets) : 0
  subnet_id     = values(aws_subnet.public_subnets)[count.index].id
  allocation_id = aws_eip.nat_gw_eips[count.index].id
  tags = {
    "Name" = "${values(aws_subnet.public_subnets)[count.index].availability_zone}: ${aws_eip.nat_gw_eips[count.index].public_ip} - VPC ${var.name}"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  for_each = zipmap(values(aws_subnet.private_subnets)[*].cidr_block, values(aws_subnet.private_subnets)[*].availability_zone)
  vpc_id   = aws_vpc.vpc.id
  tags = {
    "Name" = "Private subnet routes ${each.key} ${each.value} - VPC ${var.name}"
  }
}

resource "aws_route_table_association" "private_rt_assocs" {
  count          = length(var.az_private_subnets)
  subnet_id      = values(aws_subnet.private_subnets)[count.index].id
  route_table_id = values(aws_route_table.private_rt)[count.index].id
}

# TODO: No az_public_subnets == no nat_gws == no private_default_route. If a
# TODO: private_default_route is necessary, add another gateway (resource) type
resource "aws_route" "private_default_route" {
  count                  = length(var.az_private_subnets) > 0 ? length(var.az_public_subnets) : 0
  route_table_id         = values(aws_route_table.private_rt)[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gws[count.index].id
  depends_on             = [aws_route_table.private_rt]
}

resource "aws_route53_zone" "internal_dns_zone" {
  name = var.internal_dns_domainname
  vpc {
    vpc_id     = aws_vpc.vpc.id
    vpc_region = var.aws_region
  }
  comment = "Internal DNS Zone - VPC ${var.name}"
  # tags = {
  #   "Name" = ""
  # }
}

resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  domain_name         = var.internal_dns_domainname
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    "Name" = "DHCP Options set - VPC ${var.name}"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options_assoc" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.vpc_dhcp_options.id
}

# TODO: Populate egress/ingress rules via variable(s), with default as described
# resource "aws_default_security_group" "default" {
#   vpc_id = aws_vpc.vpc.id
#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = -1
#     self      = true
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
