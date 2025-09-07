
locals  {
    common_tags = {
        Environment = var.environment
        Service     = "cicd"
        Owner       = var.owner
        CostCenter  = var.cost_center
        Compliance  = var.compliance
        Project     = var.project
        Backup      = "true"
    }
}

resource "aws_s3_bucket" "tf_state" {
    bucket = var.bucket_name
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-tfstate"
        }
    )
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
    bucket = aws_s3_bucket.tf_state.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
    bucket = aws_s3_bucket.tf_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
    bucket = aws_s3_bucket.tf_state.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_state" {
    bucket = aws_s3_bucket.tf_state.id

    rule {
        id     = "retain-older-state-versions"
        status = "Enabled"

        noncurrent_version_transition {
            noncurrent_days = 30
            storage_class   = "STANDARD_IA"
        }

        noncurrent_version_transition {
            noncurrent_days = 90
            storage_class   = "GLACIER"
        }

        noncurrent_version_expiration {
            noncurrent_days = 365
        }
        filter {}
    }

    rule {
        id     = "expire-multipart-uploads"
        status = "Enabled"

        abort_incomplete_multipart_upload {
            days_after_initiation = 7
        }
        filter {}
    }
}

output state_bucket_name {
  value       = aws_s3_bucket.tf_state.bucket
  description = "Name of the S3 bucket for Terraform state"
}
