# Bootstrap variables for S3 bucket
variable "project" {
  type        = string
  default     = "vtd-devops-khangkieu"
  description = "Project name for tagging and naming resources"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Environment name for tagging and naming resources"
}

variable "owner" {
  type        = string
  default     = "kieukhang185@gmail.com"
  description = "Owner tag (email/alias)"
}

variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region to deploy resources"
}

variable "cost_center" {
  type        = string
  default     = "devopskit"
  description = "Cost center tag"
}

variable "bucket_name" {
  # devopskit-prod-tfstate-1234
  type        = string
  description = "Globally-unique S3 bucket name for Terraform state (e.g., devopskit-prod-tfstate-1234)"
}

variable "compliance" {
  type        = string
  default     = "internal"
  description = "Compliance tag"
}

variable "enable_mfa_delete" {
  type        = bool
  default     = false
  description = "Enable MFA Delete on the S3 bucket (requires AWS CLI for certain operations)"
}
