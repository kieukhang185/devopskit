terraform {
  backend "s3" {
    bucket         = "devopskit-dev-tfstate-1234" # REPLACE with your unique bucket name from E1-S3
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devopskit-dev-tflock" # REPLACE if you used a different name in E1-S2
    encrypt        = true
  }
}
