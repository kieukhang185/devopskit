# ALB module variables
variable "name_prefix" {
  description = "Prefix for ALB resources (e.g., todo-dev)"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the ALB lives"
  type        = string
}

variable "subnet_ids" {
  description = "PUBLIC subnet IDs for the ALB (>= 2 AZs)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups to attach to the ALB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Protect ALB from accidental deletion"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "ALB idle timeout (seconds)"
  type        = number
  default     = 60
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid header fields at ALB"
  type        = bool
  default     = true
}

# Listeners / routing
variable "enable_http" {
  description = "Create HTTP (80) listener"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Create HTTPS (443) listener"
  type        = bool
  default     = true
}

variable "http_to_https_redirect" {
  description = "If true, HTTP listener redirects to HTTPS"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (must be in same region as ALB)"
  type        = string
  default     = null
}

variable "default_target_group_arn" {
  description = "Optional default Target Group ARN for listeners (forward action). If null, listeners return a fixed 200 response."
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
