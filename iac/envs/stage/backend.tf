# Terraform backend configuration for S3 and DynamoDB
terraform {
  backend "s3" {
    bucket         = "devopskit-stage-tfstate-1234" # REPLACE with your unique bucket name from E1-S3
    key            = "envs/stage/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "devopskit-stage-tflock" # REPLACE if you used a different name in E1-S2
    encrypt        = true
  }
}
