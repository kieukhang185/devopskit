output "arn" {
  description = "CodeStar connection ARN"
  value       = aws_codestarconnections_connection.this.arn
}

output "status" {
  description = "Connection status (PENDING until you complete the console handshake)"
  value       = aws_codestarconnections_connection.this.connection_status
}

output "name" {
  description = "CodeStar connection name"
  value       = aws_codestarconnections_connection.this.name
}
