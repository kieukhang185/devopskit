module "web_iam" {
  source = "./iam-ec2-web"
}
module "api_iam" {
  source = "./iam-ec2-api"
}
