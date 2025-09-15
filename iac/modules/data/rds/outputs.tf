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

output "master_user_secret_arn" {
  description = "ARN of Secrets Manager secret that stores the RDS master password"
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}

output "parameter_group_name" { value = local.effective_parameter_group }
