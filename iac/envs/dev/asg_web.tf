
module "asg_web" {
  source = "../../modules/asg"

  name_prefix   = "todo-web-dev"
  service       = "web"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "devopskit-key"

  target_group_arns    = [aws_lb_target_group.web.arn]
  iam_instance_profile = module.web_iam.web_instance_profile_name
  security_group_ids   = [aws_security_group.web.id]
  subnet_ids           = module.vpc.public_subnet_ids
  kms_key_id           = data.aws_kms_key.ebs_default.arn

  user_data_base64 = filebase64("${path.module}/userdata/web/user-data.sh")

  desired_capacity = 2
  min_size         = 1
  max_size         = 2

  project     = "vtd-devops-khangkieu"
  environment = "dev"
  owner       = "kieukhang1805@gmail.com"
  cost_center = "devopskit"
  compliance  = "internal"

  extra_tags = {
    Tier = "app"
  }
  depends_on = [module.web_iam]
}

# Keep CPU around 50% across the group
resource "aws_autoscaling_policy" "web_cpu_target" {
  name                   = "web-cpu-target"
  autoscaling_group_name = module.asg_web.auto_scaling_group_name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value     = 50    # aim for ~50% average CPU
    disable_scale_in = false # allow scale in when low
  }
}
