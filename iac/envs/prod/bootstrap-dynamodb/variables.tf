# Bootstrap variables for DynamoDB table
variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "vtd-devops-khangkieu"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "table_name" {
  description = "DynamoDB table name for Terraform state locking (e.g., devopskit-prod-tflock)"
  type        = string
  default     = "devopskit-prod-tflock"
}

variable "owner" {
  description = "Owner tag (email/alias)"
  type        = string
  default     = "kieukhang1805@gmail.com"
}

variable "cost_center" {
  description = "CostCenter tag"
  type        = string
  default     = "devopskit"
}

variable "compliance" {
  description = "Compliance tag"
  type        = string
  default     = "internal"
}
