
data "aws_secretsmanager_secret" "rds_master" {
  arn = module.rds.master_user_secret_arn
}

resource "aws_secretsmanager_secret_rotation" "rds_master_rotation" {
  secret_id = data.aws_secretsmanager_secret.rds_master.arn
  rotation_rules { automatically_after_days = 30 }
}
