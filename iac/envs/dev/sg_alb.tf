# Security Group for Application Load Balancer (ALB)

resource "aws_security_group" "alb" {
  name        = "todo-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  # Allow HTTP (port 80) from anywhere
  ingress {
    description      = "Allow HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow HTTPS (port 443) from anywhere
  ingress {
    description      = "Allow HTTPS from anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow all outbound traffic so ALB can reach backends
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.required_tags, {
    Name    = "todo-${var.environment}-alb-sg"
    Service = "alb"
    Tier    = "web"
  })
}

# Allow inbound HTTP traffic from ALB security group to web server security group
# Web: allow HTTP 80 from ALB SG
resource "aws_security_group_rule" "web_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow HTTP from ALB"
}

# (Optional) If your web instances terminate HTTPS themselves:
# resource "aws_security_group_rule" "web_from_alb_443" {
#   type                     = "ingress"
#   description              = "HTTPS from ALB"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.alb.id
#   security_group_id        = aws_security_group.web.id
# }

# API: allow HTTP 8080 from ALB SG
resource "aws_security_group_rule" "api_from_alb_8080" {
  type                     = "ingress"
  description              = "API 8080 from ALB"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.api.id
}
