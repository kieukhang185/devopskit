# Scale OUT when avg CPU >= 70% for 2x60s
resource "aws_cloudwatch_metric_alarm" "api_high_cpu" {
  alarm_name          = "api-high-cpu"
  alarm_description   = "Scale out when API CPU >= 70%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 70
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    AutoScalingGroupName = module.asg_api.auto_scaling_group_name
  }

  alarm_actions = [aws_autoscaling_policy.api_scale_out.arn]
}

# Scale IN when avg CPU <= 30% for 3x60s
resource "aws_cloudwatch_metric_alarm" "api_low_cpu" {
  alarm_name          = "api-low-cpu"
  alarm_description   = "Scale in when API CPU <= 30%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 3
  threshold           = 30
  comparison_operator = "LessThanOrEqualToThreshold"

  dimensions = {
    AutoScalingGroupName = module.asg_api.auto_scaling_group_name
  }

  alarm_actions = [aws_autoscaling_policy.api_scale_in.arn]
}

# Simple scaling policies tied to the alarms above
resource "aws_autoscaling_policy" "api_scale_out" {
  name                   = "api-scale-out"
  autoscaling_group_name = module.asg_api.auto_scaling_group_name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1 # add 1 instance
  cooldown               = 120
}

resource "aws_autoscaling_policy" "api_scale_in" {
  name                   = "api-scale-in"
  autoscaling_group_name = module.asg_api.auto_scaling_group_name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1 # remove 1 instance
  cooldown               = 180
}
