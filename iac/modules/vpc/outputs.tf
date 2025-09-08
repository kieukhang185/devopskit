# VPC Module Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_tags" {
  description = "Tags applied to the VPC"
  value       = aws_vpc.this.tags
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for idx in sort(keys(aws_subnet.public)) : aws_subnet.public[idx].id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for idx in sort(keys(aws_subnet.private)) : aws_subnet.private[idx].id]
}

output "data_subnet_ids" {
  description = "IDs of the data subnets"
  value       = [for idx in sort(keys(aws_subnet.data)) : aws_subnet.data[idx].id]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "public_route_table_association_ids" {
  description = "IDs of the public route table associations"
  value       = [for k, v in aws_route_table_association.public : v.id]
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

output "vpc_endpoint_s3_id" {
  description = "ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_ssm_ids" {
  description = "IDs of the SSM Interface VPC Endpoints"
  value       = { for k, vpce in aws_vpc_endpoint.ssm : k => vpce.id }
}

output "vpc_endpoint_sg_id" {
  description = "ID of the security group for VPC endpoints"
  value       = aws_security_group.endpoints.id
}

output "vpc_endpoint_secretsmanager_id" {
  description = "ID of the Secrets Manager Interface VPC Endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "vpc_endpoint_logs_id" {
  description = "ID of the CloudWatch Logs Interface VPC Endpoint"
  value       = aws_vpc_endpoint.logs.id
}
