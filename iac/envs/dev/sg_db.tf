# Security Group for DB instances
resource "aws_security_group" "db" {
  name        = "dev-db-sg"
  description = "PostgreSQL access from API tier only"
  vpc_id      = module.vpc.vpc_id

  # Ingress: only API SG can connect on 5432
  ingress {
    description = "Postgres from API"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_security_group.api.id
    ]
  }

  # Egress: allow all (for OS updates, monitoring agents, etc.)
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.required_tags, {
    Name    = "${var.environment}-db-sg"
    Service = "db"
    Tier    = "data"
  })
}
