# RDS Postgres instance for dev environment
# Subnet group (RDS runs in private subnets)
resource "aws_db_subnet_group" "postgres" {
  name       = "dev-postgres-subnets"
  subnet_ids = module.vpc.private_subnet_ids

  tags = merge(local.required_tags, {
    Name    = "${var.environment}-postgres-subnets"
    Service = "db"
  })
}

# Optional: custom parameter group (example forces SSL)
resource "aws_db_parameter_group" "postgres" {
  name   = "dev-postgres16-params"
  family = "postgres16" # match engine version below
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = merge(local.required_tags, {
    Name = "${var.environment}-postgres16-params"
  })
}

# Generate a strong master password and store it in SSM
resource "random_password" "rds_master" {
  length  = 30
  special = true
}

resource "aws_ssm_parameter" "rds_master_password" {
  name        = "/devopskit/dev/db/master_password"
  description = "RDS master password (dev)"
  type        = "SecureString"
  value       = random_password.rds_master.result
}

# Security group for RDS (ingress only from web/api SGs)
resource "aws_security_group" "rds" {
  name        = "dev-rds-sg"
  description = "RDS Postgres access from web/api only"
  vpc_id      = module.vpc.vpc_id

  # No wide-open ingress here; rules defined below
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.required_tags, {
    Name    = "${var.environment}-rds-sg"
    Service = "db"
  })
}

resource "aws_security_group_rule" "rds_from_web" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = aws_security_group.rds.id
  description              = "Postgres from web"
}

resource "aws_security_group_rule" "rds_from_api" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.api.id
  security_group_id        = aws_security_group.rds.id
  description              = "Postgres from api"
}

# The RDS instance
resource "aws_db_instance" "postgres" {
  identifier            = "todo-dev-postgres"
  engine                = "postgres"
  engine_version        = "16.4" # adjust as needed
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100 # autoscaling storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = data.aws_kms_key.ebs_default.arn

  username = "masteruser"
  password = random_password.rds_master.result
  db_name  = "tododb"

  port                   = 5432
  multi_az               = false # set true for HA
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  parameter_group_name   = aws_db_parameter_group.postgres.name

  backup_retention_period = 7
  backup_window           = "19:45-20:15"
  maintenance_window      = "Mon:20:30-Mon:21:00"

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "todo-dev-postgres-final"

  # Performance Insights (optional; helpful in prod)
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = data.aws_kms_key.ebs_default.arn
  performance_insights_retention_period = 7

  # Faster DNS TTL on failover (if multi_az=true)
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(local.required_tags, {
    Name    = "todo-${var.environment}-postgres"
    Service = "db"
  })

  depends_on = [
    aws_db_subnet_group.postgres,
    aws_security_group.rds
  ]
}

output "rds_endpoint" { value = aws_db_instance.postgres.address }
output "rds_port" { value = aws_db_instance.postgres.port }
output "rds_db_name" { value = aws_db_instance.postgres.db_name }
output "rds_master_user" { value = aws_db_instance.postgres.username }
output "rds_sg_id" { value = aws_security_group.rds.id }
output "rds_master_pw_ssm" { value = aws_ssm_parameter.rds_master_password.name }
