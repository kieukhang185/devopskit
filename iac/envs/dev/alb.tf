# Application Load Balancer for Dev Environment

locals {
  use_https       = false # flip to true when you have ACM cert
  certificate_arn = null  # replace with your ACM ARN when ready
}

module "alb" {
  source = "../../modules/alb"

  name_prefix        = "todo-${var.environment}"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.alb.id]

  enable_http            = true
  enable_https           = local.use_https
  http_to_https_redirect = local.use_https
  certificate_arn        = local.certificate_arn

  default_target_group_arn = aws_lb_target_group.web.arn

  tags = merge(local.required_tags, {
    Name    = "todo-${var.environment}-alb"
    Service = "alb"
    Tier    = "web"
  })
}

resource "aws_lb_listener_rule" "api_path" {
  listener_arn = coalesce(
    # module.alb.https_listener_arn,
    module.alb.http_listener_arn
  )

  priority = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

output "alb_dns_name" {
  value = module.alb.alb_dns
}
