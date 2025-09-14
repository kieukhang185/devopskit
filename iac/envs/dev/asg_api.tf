data "aws_kms_key" "ebs_default" {
  key_id = "alias/dev-ebs-default"
}

module "asg_api" {
  source = "../../modules/asg"

  name_prefix   = "todo-api-dev"
  service       = "api"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "devopskit-key"
  iam_instance_profile = module.api_iam.api_instance_profile_name
  security_group_ids = [aws_security_group.api.id]
  subnet_ids         = module.vpc.public_subnet_ids
  kms_key_id        = data.aws_kms_key.ebs_default.arn

  user_data_base64 = filebase64("${path.module}/userdata/api/user-data.sh")

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
  depends_on = [module.api_iam]
}
