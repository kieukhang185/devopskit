output "security_group_id" {
  value       = aws_security_group.rds.id
  description = "The ID of the RDS security group"
}
output "db_instance_id" {
  value       = aws_db_instance.this.id
  description = "The ID of the RDS instance"
}
output "endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "The endpoint of the RDS instance"
}
output "address" {
  value       = aws_db_instance.this.address
  description = "The address of the RDS instance"
}
output "port" {
  value       = aws_db_instance.this.port
  description = "The port of the RDS instance"
}
output "arn" {
  value       = aws_db_instance.this.arn
  description = "The ARN of the RDS instance"
}
