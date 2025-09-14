# Terraform configuration for Auto Scaling Group (ASG) module
locals {
  base_tags = merge(
    {
      Name        = var.name_prefix
      Project     = var.project
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Compliance  = var.compliance
      Backup      = var.backup
      Service     = var.service
    },
    var.extra_tags
  )
}

# Launch template
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.root_volume_size_gb
      volume_type           = var.root_volume_type
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = var.kms_key_id # Optional: specify a KMS key ID for encryption
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_ids
  }

  user_data = var.user_data_base64 == null ? "" : var.user_data_base64

  tag_specifications {
    resource_type = "instance"

    tags = local.base_tags
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name                = "${var.name_prefix}-asg"
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  health_check_type   = "EC2"
  force_delete        = true
  target_group_arns   = var.target_group_arns

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = var.name_prefix
  }

  dynamic "tag" {
    for_each = { for k, v in local.base_tags : k => v if k != "Name" }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
