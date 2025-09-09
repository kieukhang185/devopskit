# Provider-level tasg applied to every resource
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "prod"
      Project     = "vtd-devops-khangkieu"
      Owner       = "kieukhang1805@gmail.com"
      CostCenter  = "devopskit"
      Compliance  = "internal"
      Backup      = "true"
    }
  }
}
