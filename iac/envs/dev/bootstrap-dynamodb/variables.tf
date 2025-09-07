variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "vtd-devops-khangkieu"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "DynamoDB table name for Terraform state locking (e.g., devopskit-dev-tflock)"
  type        = string
  default     = "devopskit-dev-tflock"
}

variable "owner" {
  description = "Owner tag (email/alias)"
  type        = string
  default     = "kieukhang1805@gmail.com"
}

variable "cost_center" {
  description = "CostCenter tag"
  type        = string
  default     = "devops"
}

variable "compliance" {
  description = "Compliance tag"
  type        = string
  default     = "internal"
}
