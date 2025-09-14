data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Reference your default EBS CMK by alias from E1-S13
data "aws_kms_key" "ebs_default" {
  key_id = "alias/dev-ebs-default"
}

# --- IAM role for web instances ---
resource "aws_iam_role" "web" {
  name = "dev-web-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

# Attach AWS managed policies for SSM & CloudWatch Agent (logs)
resource "aws_iam_role_policy_attachment" "web_ssm" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "web_cwagent" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Custom inline policy: allow using the EBS default CMK
resource "aws_iam_policy" "web_kms_ebs" {
  name        = "dev-web-kms-ebs-use"
  description = "Allow EC2 role to use the default EBS CMK for volume encryption"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "UseEBSDefaultCMK",
        Effect: "Allow",
        Action: [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        Resource: data.aws_kms_key.ebs_default.arn,
        Condition: {
          "Bool": { "kms:GrantIsForAWSResource": "true" }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "web_kms_attach" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.web_kms_ebs.arn
}

# Instance profile to attach in Launch Template
resource "aws_iam_instance_profile" "web" {
  name = "dev-web-ec2-profile"
  role = aws_iam_role.web.name
}

output "web_instance_profile_name" {
  value = aws_iam_instance_profile.web.name
}
output "web_role_arn" {
  value = aws_iam_role.web.arn
}
output "ebs_default_key_arn" {
  value = data.aws_kms_key.ebs_default.arn
}
