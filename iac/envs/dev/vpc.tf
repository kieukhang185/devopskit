# Create VPC and subnets for dev environment
module "vpc" {
  source = "../../modules/vpc"

  name_prefix = "dev"
  cidr_block  = "10.10.0.0/16"

  public_subnet_cidrs  = ["10.10.0.0/24", "10.10.1.0/24"]
  private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
  data_subnet_cidrs    = ["10.10.20.0/24", "10.10.21.0/24"]

  project     = "vtd-devops-khangkieu"
  environment = "dev"
  owner       = "khangkieu1805@gmail.com"
  cost_center = "devopskit"
  compliance  = "internal"

  # keep true to align with tagging policy defaults
  backup = "true"

  # Optional extra tags
  extra_tags = {
    Service = "networking"
  }
}
