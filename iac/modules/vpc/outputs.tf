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
