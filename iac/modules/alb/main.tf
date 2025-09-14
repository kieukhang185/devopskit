# Create an Application Load Balancer (ALB)
resource "aws_lb" "this" {
  name                       = "${var.name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = var.drop_invalid_header_fields

  security_groups = var.security_group_ids
  subnets         = var.subnet_ids

  tags = merge(
    { Name = "${var.name_prefix}-alb" },
    var.tags
  )
}

# Create HTTPS listener if enabled
# 80 redirect -> 443 (only if HTTP enabled AND https redirect requested)
resource "aws_lb_listener" "http_redirect" {
  count             = var.enable_http && var.http_to_https_redirect ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create HTTPS listener if enabled
# 80 forward to TG (when HTTP enabled AND NOT redirect AND default TG provided)
resource "aws_lb_listener" "http_forward" {
  count             = var.enable_http && !var.http_to_https_redirect && var.default_target_group_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.default_target_group_arn
  }
}

# Create HTTP listener with fixed 200 response (when HTTP enabled AND NOT redirect AND NO default TG)
resource "aws_lb_listener" "http_fixed" {
  count             = var.enable_http && !var.http_to_https_redirect && var.default_target_group_arn == null ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}
