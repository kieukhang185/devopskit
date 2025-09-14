# Enable default EBS encryption (account+region scope) and set a CMK as the default key.
# aws_ebs_encryption_by_default and aws_ebs_default_kms_key apply to all new EBS volumes create in this AWS account + region

data "aws_caller_identity" "current" {}

# KMS CMK dedicated for EBS default encryption (dev)
resource "aws_kms_key" "ebs_default" {
  description             = "KMS key for EBS encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.ebs_kms.json
  tags = {
    Name        = "${var.project}-${var.environment}-ebs-key"
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
  }
}

# Create an alias for the KMS key
resource "aws_kms_alias" "ebs_default" {
  name          = "alias/${var.environment}-ebs-default"
  target_key_id = aws_kms_key.ebs_default.key_id
}

# IAM policy document for the KMS key
data "aws_iam_policy_document" "ebs_kms" {
  statement {
    sid    = "EnableRootAccountAdmin"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

  # Policy for Auto Scaling service role
  statement {
    sid    = "AllowAutoScalingServiceLinkedRoleUseOfKey"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:ListGrants"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
  }
  }
}

resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

# Associate the KMS key with EBS default encryption
resource "aws_ebs_default_kms_key" "this" {
  key_arn    = aws_kms_key.ebs_default.arn
  depends_on = [aws_ebs_encryption_by_default.this]
}

output "aws_ebs_default_kms_key" {
  description = "ARN of the KMS key used for EBS encryption"
  value       = aws_kms_key.ebs_default.arn
}

output "ebs_default_kms_key_alias" {
  description = "Alias of the default EBS KMS key"
  value       = aws_kms_alias.ebs_default.name
}
