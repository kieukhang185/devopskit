# Outputs for ALB module
output "alb_arn" { value = aws_lb.this.arn }
output "alb_id" { value = aws_lb.this.id }
output "alb_dns" { value = aws_lb.this.dns_name }
output "alb_zone_id" { value = aws_lb.this.zone_id }

output "http_listener_arn" {
  value = coalesce(
    try(aws_lb_listener.http_redirect[0].arn, null),
    try(aws_lb_listener.http_forward[0].arn, null),
    try(aws_lb_listener.http_fixed[0].arn, null)
  )
}

# output "https_listener_arn" {
#   value = coalesce(
#     try(aws_lb_listener.https_forward[0].arn, null),
#     try(aws_lb_listener.https_fixed[0].arn, null)
#   )
# }
