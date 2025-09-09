# KMS key for S3 bucket
data "aws_caller_identity" "current" {}

# IAM policy document for KMS key
resource "aws_kms_key" "s3_state" {
  description             = "KMS key for S3 bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_s3_state.json

  tags = {
    Name        = "s3-tfstate-kms"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = "true"
  }
}

resource "aws_kms_alias" "s3_state" {
  name          = "alias/s3-tfstate-kms"
  target_key_id = aws_kms_key.s3_state.key_id
}

# IAM policy document for KMS key
data "aws_iam_policy_document" "kms_s3_state" {
  # Root of this account can administer the key
  statement {
    sid    = "EnableRootAdmin"
    effect = "Allow"
    actions = [
      "kms:*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = ["*"]
  }

  # Allow use of the CMK by IAM policies in this account
  statement {
    sid    = "AllowUseFromThisAccount"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"
    ]
  }
}

# CMK for s3 logs bucket
resource "aws_kms_key" "s3_logs" {
  description             = "CMK for S3 logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_s3_logs.json
  tags = {
    Name        = "s3-logs-kms"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = "true"
  }
}

resource "aws_kms_alias" "s3_logs" {
  name          = "alias/s3-logs-kms"
  target_key_id = aws_kms_key.s3_logs.key_id
}

data "aws_iam_policy_document" "kms_s3_logs" {
  # Root of this account can administer the key
  statement {
    sid    = "EnableRootAdmin"
    effect = "Allow"
    actions = [
      "kms:*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  # Allow use of the CMK by IAM
  statement {
    sid    = "AllowUseFromThisAccount"
    effect = "Allow"
    principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

output kms_s3_state_key_arn {
  value       = "aws_kms_key.s3_state.arn"
  description = "KMS key ARN for Terraform state"
}

output kms_s3_logs_key_arn {
  value       = "aws_kms_key.s3_logs.arn"
  description = "KMS key ARN for S3 logs"
}
