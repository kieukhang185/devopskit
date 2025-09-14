data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Use your default EBS CMK from E1-S13
data "aws_kms_key" "ebs_default" {
  key_id = "alias/dev-ebs-default"
}

resource "aws_iam_role" "api" {
  name = "dev-api-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Principal={ Service="ec2.amazonaws.com" }, Action="sts:AssumeRole" }]
  })
}

# Managed policies for SSM + CW Agent
resource "aws_iam_role_policy_attachment" "api_ssm" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "api_cwagent" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Allow using the default EBS CMK
resource "aws_iam_policy" "api_kms_ebs" {
  name        = "dev-api-kms-ebs-use"
  description = "Allow API EC2 role to use default EBS CMK"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid="UseEBSDefaultCMK", Effect="Allow",
      Action=[
        "kms:Encrypt","kms:Decrypt","kms:ReEncrypt*","kms:GenerateDataKey*","kms:DescribeKey","kms:CreateGrant"
      ],
      Resource = data.aws_kms_key.ebs_default.arn,
      Condition = { Bool = { "kms:GrantIsForAWSResource": "true" } }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "api_kms_attach" {
  role       = aws_iam_role.api.name
  policy_arn = aws_iam_policy.api_kms_ebs.arn
}

resource "aws_iam_instance_profile" "api" {
  name = "dev-api-ec2-profile"
  role = aws_iam_role.api.name
}

output "api_instance_profile_name" { value = aws_iam_instance_profile.api.name }
output "api_role_arn"             { value = aws_iam_role.api.arn }
