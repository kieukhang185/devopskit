
variable "environment" {
  description = "The environment for the resources (e.g., dev, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "prod", "stage"], var.environment)
    error_message = "Environment must be one of 'dev', 'prod', or 'stage'."
  }
}

variable "owner" {
  description = "The owner of the resources"
  type        = string
  default     = "kieukhang1805@gmail.com"
    validation {
        condition     = length(trim(var.owner)) > 0 && can(regex("@", var.owner))
        error_message = "Owner cannot be a non-empty email/alias (contains '@')."
    }
}

variable "cost_center" {
  description = "The cost center for billing purposes"
  type        = string
  default     = "devopskit"
    validation {
        condition     = length(trim(var.cost_center)) > 0
        error_message = "Cost center cannot be empty."
    }
}

variable "compliance" {
  description = "Compliance level of the resources"
  type        = string
  default     = "internal"
    validation {
        condition     = contains(["internal","public"], var.compliance)
        error_message = "Compliance must be one of 'internal' or 'public'."
    }
}

variable "backup" {
  description = "Indicates if the resource should be backed up"
  type        = string
  default     = "true"
    validation {
        condition     = contains(["true","false"], lower(var.backup))
        error_message = "Backup must be either 'true' or 'false'."
    }
}

locals {
  required_tags = {
    Project     = "vtd-devops-khangkieu"
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = var.backup
  }
}

output "required_tags_preview" {
  description = "A map of required tags for resources"
  value       = local.required_tags
}
