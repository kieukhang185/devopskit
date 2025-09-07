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
