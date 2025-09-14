
variable "name" {
  type        = string
  description = "The name of the RDS instance, used as a prefix for resources"
}

variable "environment" {
  type        = string
  description = "The environment (e.g., dev, prod)"
}

variable "engine_version" {
  type        = string
  default     = "14.11"
  description = "PostgreSQL engine version"
}
variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the RDS subnet group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where RDS will be deployed"
}

variable "api_sg_id" {
  type        = string
  description = "Security Group ID of API tier allowed to reach DB"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS Key ID for storage encryption, null for default AWS RDS key"
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage size in GiB"
}

variable "max_allocated_storage" {
  type        = number
  default     = 200
  description = "Max allocated storage size in GiB"
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Enable deletion protection"
}

variable "backup_retention" {
  type        = number
  default     = 7
  description = "Backup retention period in days"
}

variable "backup_window" {
  type        = string
  default     = "20:00-21:00"
  description = "Backup window in UTC"
}

variable "maintenance_window" {
  type        = string
  default     = "Sun:21:00-Sun:22:00"
  description = "Preferred maintenance window in UTC"
}

variable "db_name" {
  type    = string
  default = "tododb"
}

variable "master_username" {
  type        = string
  default     = "devopskituser"
  description = "Master username for the RDS instance"
}
variable "parameter_overrides" {
  description = "Extra DB parameters to merge into the parameter group"
  type        = map(string)
  default     = {}
}

# allow attaching a custom parameter group name from outside if desired
variable "parameter_group_name" {
  type    = string
  default = null
}

variable "performance_insights_enabled" {
  type        = bool
  default     = true
  description = "Enable performance insights"
}

variable "performance_insights_retention_period" {
  type        = number
  default     = 7
  description = "Performance insights retention period in days"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the resources"
}
