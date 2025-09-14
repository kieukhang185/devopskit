# Variables for Auto Scaling Group module
variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
}

# Name of the environment (e.g., dev, staging, prod)
variable "service" {
  description = "Service name web|api"
  type        = string
}

# Name of the environment (e.g., dev, staging, prod)
variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

# List of security group IDs
variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

# Desired number of instances in the Auto Scaling Group
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

# EC2 instance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Key pair name for SSH access
variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired capacity for the Auto Scaling Group"
  type        = number
  default     = 2
}

# Volume size for the root EBS volume in GB
variable "root_volume_size_gb" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}

# Volume type for the root EBS volume (e.g., gp3, gp2, io1, st1, sc1)
variable "root_volume_type" {
  description = "Type of the root EBS volume"
  type        = string
  default     = "gp3"
}

# Tags
variable "project" {
  description = "Project name"
  type        = string
  default     = "vtd-devops-khangkieu"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "kiekhang1805@gmail.com"
}

variable "cost_center" {
  description = "Cost center identifier"
  type        = string
  default     = "devopskit"
}

variable "compliance" {
  description = "Compliance information"
  type        = string
  default     = "internal"
}

variable "backup" {
  description = "Backup information"
  type        = string
  default     = "true"
}

variable "extra_tags" {
  description = "Map of additional tags to add to resources"
  type        = map(string)
  default     = {}
}

variable "user_data_base64" {
  description = "Base64-encoded user-data script"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS Key ID for EBS volume encryption (optional)"
  type        = string
  default     = null
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "List of target group ARNs to attach to the ASG"
}
