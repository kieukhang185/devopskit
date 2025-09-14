# Terraform variables for EBS encryption module
variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "vtd-devops-khangkieu"
}
variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
  default     = "kieukhang1805@gmail.com"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing"
  default     = "devopskit"
}

variable "compliance" {
  type        = string
  description = "Compliance requirements"
  default     = "internal"
}
