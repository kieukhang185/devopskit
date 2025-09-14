# VPC Module

variable "required_tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

locals {
  all_tags = merge(var.required_tags, var.extra_tags, {
    Name = "devopskit-${var.environment}-vpc"
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = var.backup
  })
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = local.all_tags
  lifecycle {
    precondition {
      condition     = alltrue([for k in ["Project","Environment","Owner","CostCenter","Compliance","Backup"] : contains(keys(local.all_tags), k)])
      error_message = "Missing one or more required tags in local.all_tags."
    }
  }
}
