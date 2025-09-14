# Security Group for API instances
resource "aws_security_group" "api" {
  name        = "dev-api-sg"
  description = "Allow traffic from web tier to API, allow egress to DB"
  vpc_id      = module.vpc.vpc_id

  # Ingress: from web SG only (e.g., port 8080)
  ingress {
    description     = "Allow HTTP from web SG"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # Egress: allow API → DB SG on Postgres
  # egress {
  #   description     = "Allow Postgres to DB SG"
  #   from_port       = 5432
  #   to_port         = 5432
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.db.id] # db SG will be defined in E2-S9
  # }

  # Optional: wide egress until db SG exists
  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = merge(local.required_tags, {
    Name    = "${var.environment}-api-sg"
    Service = "api"
    Tier    = "app"
  })
}
