output "id" {
  value       = aws_vpc.vpc-ecs.id
  description = "VPC ID"
}

# output "public_subnet1_ids" {
#   value       = aws_subnet.subnet-pub-1.id
#   description = "List of public subnet IDs"
# # }

# output "public_subnet2_ids" {
#   value       = aws_subnet.subnet-pub-2.id
#   description = "List of public subnet IDs"
# }

# output "private_subnet1_ids" {
#   value       = aws_subnet.subnet-priv-1.id
#   description = "List of private subnet IDs"
# }

# output "private_subnet2_ids" {
#   value       = aws_subnet.subnet-priv-2.id
#   description = "List of private subnet IDs"
# }

#
output "public_subnet_ids" {
  value       = aws_subnet.subnet-pub.*.id
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = aws_subnet.subnet-priv.*.id
  description = "List of private subnet IDs"
}

output "cidr_block" {
  value       = var.cidr_block
  description = "The CIDR block associated with the VPC"
}

# output "nat_gateway_ips" {
#   value       = aws_nat_gateway.mynat.id
#   description = "List of Elastic IPs associated with NAT gateways"
# }

output "nat_gateway_ips" {
  value       = aws_eip.nat.*.public_ip
  description = "List of Elastic IPs associated with NAT gateways"
}

output "igw_ips" {
  value       = aws_internet_gateway.igw.id
  description = "igw id"
}


