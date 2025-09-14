# Provider-level tasg applied to every resource
provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      Environment = "stage"
      Project     = "vtd-devops-khangkieu"
      Owner       = "kieukhang1805@gmail.com"
      CostCenter  = "devopskit"
      Compliance  = "internal"
      Backup      = "true"
    }
  }
}
