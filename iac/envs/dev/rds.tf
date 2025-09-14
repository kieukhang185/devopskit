module "rds" {
  source = "../../modules/data/rds"
  name   = "dev-app"
  vpc_id = module.vpc.id

  subnet_ids = [
    module.vpc.data_subnet_ids[0],
    module.vpc.data_subnet_ids[1],
  ]

  api_sg_id  = module.asg_api.security_group_id
  kms_key_id = data.aws_kms_key.data_at_rest.arn

  # Sane defaults; bump in prod
  instance_class        = "db.t3.small"
  engine_version        = "14.11"
  allocated_storage     = 20
  max_allocated_storage = 200
  multi_az              = true
  deletion_protection   = true
  backup_retention      = 7
  backup_window         = "18:00-19:00" # UTC (01:00-02:00 Asia/Ho_Chi_Minh +7)
  maintenance_window    = "Sun:19:00-Sun:20:00"

  tags = merge(local.required_tags, {
    Service = "db"
  })
}
