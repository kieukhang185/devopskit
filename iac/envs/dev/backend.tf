# Backend configuration for Terraform state
terraform {
  backend "s3" {
    bucket         = "devopskit-dev-tfstate-123abc" # REPLACE with your unique bucket name from E1-S3
    key            = "envs/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "devopskit-dev-tflock" # REPLACE if you used a different name in E1-S2
    encrypt        = true
  }
}
