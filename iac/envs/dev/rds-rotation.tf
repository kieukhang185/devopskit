data "aws_caller_identity" "current" {}

# Deploy the official rotation Lambda via SAR (PostgreSQL single-user)
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rds_rotation" {
  name             = "secretsmanager-rotation-postgresql-singleuser"
  application_id   = "arn:aws:serverlessrepo:${var.aws_region}:${data.aws_caller_identity.current.account_id}:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"
  semantic_version = "1.1.1" # check/upgrade as needed per region
  # https://docs.aws.amazon.com/serverless-application-repository/latest/devguide/serverlessrepo-creating.html
  # capabilities is needed for the IAM role the app creates
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  parameters = {
    functionName        = "secretsmanager-rotation-postgresql-singleuser"
    vpcSubnetIds        = join(",", module.vpc.data_subnet_ids)
    vpcSecurityGroupIds = module.rds.security_group_id
  }

  tags = merge(local.required_tags, {
    Environment = "dev"
    Service     = "db"
  })
}

# Attach rotation to the secret that RDS created
data "aws_secretsmanager_secret" "rds_master" {
  arn = module.rds.master_user_secret_arn
}

resource "aws_secretsmanager_secret_rotation" "rds_master_rotation" {
  secret_id           = data.aws_secretsmanager_secret.rds_master.arn
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.rds_rotation.outputs["FunctionArn"]

  rotation_rules {
    automatically_after_days = 30
  }
}
