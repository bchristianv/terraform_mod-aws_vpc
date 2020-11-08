# Outputs

output "az_private_cidrs" {
  description = "A map of availability zones to private subnet CIDR's"
  value = zipmap(values(aws_subnet.private_subnets)[*].availability_zone,
  values(aws_subnet.private_subnets)[*].cidr_block)
}

output "az_public_cidrs" {
  description = "A map of availability zones to public subnet CIDR's"
  value = zipmap(values(aws_subnet.public_subnets)[*].availability_zone,
  values(aws_subnet.public_subnets)[*].cidr_block)
}

output "cidr_block" {
  description = "The IP block of the VPC in CIDR notation"
  value = aws_vpc.vpc.cidr_block
}

output "id" {
  description = "The ID of the VPC"
  value = aws_vpc.vpc.id
}

output "internal_dns_zone_id" {
  description = "The ID of the internal DNS zone"
  value = aws_route53_zone.internal_dns_zone.zone_id
}

output "internal_dns_zone_nameservers" {
  description = "A list of the nameservers for the internal DNS zone"
  value = aws_route53_zone.internal_dns_zone.name_servers
}

output "internet_gw_id" {
  description = "The ID of the internet gateway"
  value = [for gw in aws_internet_gateway.igw : gw.id]
}

output "nat_gw_ids" {
  description = "A list of the NAT gateway ID's"
  value = aws_nat_gateway.nat_gws[*].id
}

output "private_route_table_ids" {
  description = "A list of the private route table ID's"
  value = values(aws_route_table.private_rt)[*].id
}

output "private_subnet_ids" {
  description = "A list of the private subnet ID's"
  value = values(aws_subnet.private_subnets)[*].id
}

output "public_route_table_ids" {
  description = "A list of the public route table ID's"
  value = [for rt in aws_route_table.public_rt : rt.id]
}

output "public_subnet_ids" {
  description = "A list of the public subnet ID's"
  value = values(aws_subnet.public_subnets)[*].id
}
