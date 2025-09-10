# Security Group for web instances
resource "aws_security_group" "web" {
  name        = "dev-web-sg"
  description = "Allow traffic from ALB to web instances, allow egress"
  vpc_id      = module.vpc.vpc_id

  # Ingress: ALB → web (HTTP). Later you can add HTTPS if needed.
  #   ingress {
  #     description      = "Allow HTTP from ALB SG"
  #     from_port        = 80
  #     to_port          = 80
  #     protocol         = "tcp"
  #     security_groups  = [aws_security_group.alb.id]   # ALB SG defined later in E2-S6
  #   }
  ingress {
    description = "TEMP: allow HTTP from anywhere until ALB exists"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: allow all outbound (instances reach out for updates, logs, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.required_tags, {
    Name    = "dev-web-sg"
    Service = "web"
    Tier    = "app"
  })
}
