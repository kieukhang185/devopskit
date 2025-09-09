# Terraform configuration for IAM role and policy for Terraform execution
# aws sts assume-role \
#   --role-arn arn:aws:iam::<account-id>:role/devopskit-dev-terraform-exec \
#   --role-session-name tf-dev-session

data "aws_caller_identity" "current" {}

# Allow this to be assumed by:
# AWS user now
# CI/CD in future
data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "terraform_exec" {
  name               = "${var.environment}-terraform-exec"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags = {
    Name        = "${var.environment}-terraform-exec-role"
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = "false"
  }
}



# IAM policy with baseline permissions for Terraform execution
resource "aws_iam_policy" "terraform_exec" {
  name        = "${var.environment}-terraform-exec-policy"
  description = "Policy for Terraform execution role in ${var.environment} environment"

  policy = data.aws_iam_policy_document.tf_baseline.json
}

data "aws_iam_policy_document" "tf_baseline" {
  # S3 state bucket + DyanamoDB lock table
  # # devopskit-dev-tfstate-1234
  statement {
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::devopskit-${var.environment}-tfstate-*", "arn:aws:s3:::devopskit-${var.environment}-tfstate-*/*"]
  }
  # devopskit-dev-tflock
  statement {
    actions   = ["dynamodb:*"]
    resources = ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/devopskit-${var.environment}-tflock"]
  }

  # KMS key for EBS encryption
  statement {
    actions   = ["kms:*"]
    resources = ["*"] # refine this later
  }

  # Basic EC2, IAM, CloudWatch Logs permissions
  statement {
    actions   = [
      "ec2:*",
      "iam:Get*","iam:List*",
      "iam:PassRole",
      "logs:*"
    ]
    resources = ["*"]
  }
}

# Attach the policy
resource "aws_iam_role_policy_attachment" "terraform_exec_attach" {
  role       = aws_iam_role.terraform_exec.name
  policy_arn = aws_iam_policy.terraform_exec.arn
}

output "terraform_exec_role_arn" {
  description = "ARN of the IAM role for Terraform execution"
  value       = aws_iam_role.terraform_exec.arn
}
