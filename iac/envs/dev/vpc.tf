module "vpc" {
  source = "../../modules/vpc"

  name_prefix = "dev"
  cidr_block  = "10.10.0.0/16"

  project      = "devopskit"
  environment  = "dev"
  owner        = "khang.kieu@endava.com"
  cost_center  = "devops"
  compliance   = "internal"

  # keep true to align with tagging policy defaults
  backup = "true"

  # Optional extra tags
  extra_tags = {
    Service = "networking"
  }
}
