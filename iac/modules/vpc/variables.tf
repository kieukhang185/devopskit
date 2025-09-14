# VPC Module Variables
variable "name_prefix" {
  description = "Prefix for naming (e.g., dev, stage, prod)"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block (e.g., 10.10.0.0/16)"
  default     = "10.10.0.0/16"
  type        = string
}

variable "enable_dns_support" {
  description = "Enable AWS DNS resolution in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

# Required tagging fields (per standards)
variable "project" {
  description = "Project tag"
  default     = "vtd-devops-khangkieu"
  type        = string
}

variable "environment" {
  description = "Environment tag"
  type        = string
}

variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region to deploy resources"
}

variable "owner" {
  description = "Owner tag"
  default     = "kieukhang1805@gmail.com"
  type        = string
}

variable "cost_center" {
  description = "CostCenter tag"
  default     = "devopskit"
  type        = string
}

variable "compliance" {
  description = "Compliance tag"
  default     = "internal"
  type        = string
}

variable "backup" {
  description = "Backup tag (true|false)"
  type        = string
  default     = "true"
}

variable "extra_tags" {
  description = "Additional tags to merge"
  type        = map(string)
  default     = {}
}

variable "public_subnet_cidrs" {
  description = "List of 2 CIDRs for public subnets (AZ0, AZ1)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of 2 CIDRs for private subnets (AZ0, AZ1)"
  type        = list(string)
}

variable "data_subnet_cidrs" {
  description = "List of 2 CIDRs for data subnets (AZ0, AZ1)"
  type        = list(string)
}

variable "az_count" {
  description = "Number of AZs to use (fixed at 2 for now)"
  type        = number
  default     = 2
}
