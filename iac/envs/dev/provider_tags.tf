# Provider-level tasg applied to every resource
provider "aws" {
  region = "ap-south-1"
  alias  = "with_tags"
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "vtd-devops-khangkieu"
      Owner       = "kieukhang1805@gmail.com"
      CostCenter  = "devopskit"
      Compliance  = "internal"
      Backup      = "true"
    }
  }
}
