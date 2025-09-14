# Scale OUT when CPU >= 70% for 2 periods of 60s
resource "aws_cloudwatch_metric_alarm" "web_high_cpu" {
  alarm_name          = "web-high-cpu"
  alarm_description   = "Scale out when average CPU >= 70%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 70
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    AutoScalingGroupName = module.asg_web.auto_scaling_group_name
  }

  alarm_actions = [aws_autoscaling_policy.web_scale_out.arn]
}

# Scale IN when CPU <= 30% for 3 periods of 60s
resource "aws_cloudwatch_metric_alarm" "web_low_cpu" {
  alarm_name          = "web-low-cpu"
  alarm_description   = "Scale in when average CPU <= 30%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 3
  threshold           = 30
  comparison_operator = "LessThanOrEqualToThreshold"

  dimensions = {
    AutoScalingGroupName = module.asg_web.auto_scaling_group_name
  }

  alarm_actions = [aws_autoscaling_policy.web_scale_in.arn]
}

# Simple scaling policies triggered by the alarms above
resource "aws_autoscaling_policy" "web_scale_out" {
  name                   = "web-scale-out"
  autoscaling_group_name = module.asg_web.auto_scaling_group_name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1     # add 1 instance
  cooldown               = 120
}

resource "aws_autoscaling_policy" "web_scale_in" {
  name                   = "web-scale-in"
  autoscaling_group_name = module.asg_web.auto_scaling_group_name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1    # remove 1 instance
  cooldown               = 180
}
