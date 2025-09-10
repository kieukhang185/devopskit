
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["devopskit"] # Canonical

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }
# }

module "asg_api" {
  source = "../../modules/asg"

  name_prefix   = "todo-api-dev"
  service       = "api"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "khang-kieu-demo"
  #   iam_instance_profile = aws_iam_instance_profile.web.name
  security_group_ids = [aws_security_group.sg_api.id]
  subnet_ids         = module.vpc.public_subnet_ids

  user_data_base64 = base64ecode(<<-EOF
    #!/bin/bash
    yum -y install nginx
    systemctl enable nginx
    systemctl start nginx
    echo "web $(hostname)" > /usr/share/nginx/html/index.html
    EOF
  )

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  project     = "vtd-devops-khangkieu"
  environment = "dev"
  owner       = "kieukhang1805@gmail.com"
  cost_center = "devopskit"
  compliance  = "internal"

  extra_tags = {
    Tier = "app"
  }
}
