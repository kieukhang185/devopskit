# Bootstrap outputs for S3 bucket
output "state_bucket_arn" {
  description = "ARN of the state bucket"
  value       = aws_s3_bucket.tf_state.arn
}
