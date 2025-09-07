# DynamoDB table for Terraform state locking
locals {
    common_tags = {
        Environment = var.environment
        Project     = var.project
        Owner       = var.owner
        CostCenter  = var.cost_center
        Compliance  = var.compliance
        Backup      = "true"
        Service     = "dynamodb"
    }
}

resource "aws_dynamodb_table" "tf_lock" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-tf-lock"
  })
}

output lock_table_name {
  value       = aws_dynamodb_table.tf_lock.name
  description = "Name of the DynamoDB table for Terraform state locking"
}
