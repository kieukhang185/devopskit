locals {
  base_tags = {
    Name        = "${var.name_prefix}-vpc"
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = var.backup
  }
}

resource "aws_vpc" "devopskit_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(local.base_tags, var.extra_tags)
}
