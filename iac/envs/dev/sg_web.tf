# Security Group for web instances
resource "aws_security_group" "web" {
  name        = "dev-web-sg"
  description = "Allow traffic from ALB to web instances, allow egress"
  vpc_id      = module.vpc.vpc_id

  # Ingress: ALB → web (HTTP)
  ingress {
    description     = "Allow HTTP from ALB SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Egress: allow all outbound (to internet, API SG, etc.)
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.required_tags, {
    Name    = "${var.environment}-web-sg"
    Service = "web"
    Tier    = "app"
  })
}
