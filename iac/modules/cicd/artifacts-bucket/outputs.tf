output "bucket" {
  description = "Artifacts bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "Artifacts bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "kms_key_arn" {
  description = "KMS CMK ARN for artifacts"
  value       = aws_kms_key.artifacts.arn
}
