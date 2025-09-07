# VPC Module Outputs
output "vpc_id" {
  value       = aws_vpc.devopskit_vpc.id
  description = "ID of the VPC"
}

output "vpc_arn" {
  value       = aws_vpc.devopskit_vpc.arn
  description = "ARN of the VPC"
}

output "vpc_cidr_block" {
  value       = aws_vpc.devopskit_vpc.cidr_block
  description = "CIDR block of the VPC"
}

output "vpc_tags" {
  value       = aws_vpc.devopskit_vpc.tags
  description = "Tags applied to the VPC"
}

output "public_subnet_ids" {
  value       = [for idx in sort(keys(aws_subnet.public)) : aws_subnet.public[idx].id]
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = [for idx in sort(keys(aws_subnet.private)) : aws_subnet.private[idx].id]
  description = "IDs of the private subnets"
}

output "data_subnet_ids" {
  value       = [for idx in sort(keys(aws_subnet.data)) : aws_subnet.data[idx].id]
  description = "IDs of the data subnets"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "ID of the Internet Gateway"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "ID of the public route table"
}

output "public_route_table_association_ids" {
  value       = [for k, v in aws_route_table_association.public : v.id]
  description = "IDs of the public route table associations"
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs per AZ index"
  value       = { for k, nat in aws_nat_gateway.this : k => nat.id }
}

output "private_route_table_ids" {
  description = "Private route table IDs per AZ index"
  value       = { for k, rt in aws_route_table.private : k => rt.id }
}

output "private_route_default_ids" {
  description = "Default route IDs (0.0.0.0/0) per private RT"
  value       = { for k, r in aws_route.private_default : k => r.id }
}

output "private_rt_association_ids" {
  description = "Associations of private subnets → private RT per AZ"
  value       = [for k, a in aws_route_table_association.private_assoc : a.id]
}

output "data_rt_association_ids" {
  description = "Associations of data subnets → private RT per AZ"
  value       = [for k, a in aws_route_table_association.data_assoc : a.id]
}
