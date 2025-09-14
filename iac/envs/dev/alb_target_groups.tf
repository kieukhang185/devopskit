
# web target group
resource "aws_lb_target_group" "web" {
  name        = "todo-dev-web-tg"
  vpc_id      = module.vpc.vpc_id
  protocol    = "HTTP"
  port        = 80
  target_type = "instance" # ASG launches EC2 instances

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  # Faster rolling updates; increase if need longer drain time
  deregistration_delay = 30

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 300 # 5 minutes
  }

  tags = {
    Name        = "todo-dev-web-tg"
    Project     = "vtd-devops-khangkieu"
    Environment = "dev"
    Service     = "web"
  }
}

# api target group
resource "aws_lb_target_group" "api" {
  name        = "todo-dev-api-tg"
  vpc_id      = module.vpc.vpc_id
  protocol    = "HTTP"
  port        = 80
  target_type = "instance" # ASG launches EC2 instances
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  # Faster rolling updates; increase if need longer drain time
  deregistration_delay = 30
  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 300 # 5 minutes
  }
  tags = {
    Name        = "todo-dev-api-tg"
    Project     = "vtd-devops-khangkieu"
    Environment = "dev"
    Service     = "api"
  }
}

output "web_target_group_arn" {
  value = aws_lb_target_group.web.arn
}
output "api_target_group_arn" {
  value = aws_lb_target_group.api.arn
}
