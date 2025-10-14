variable "name" {
  description = "Globally-unique S3 bucket name for CI/CD artifacts"
  type        = string
  default     = "cicd-artifacts-bucket"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "transition_ia_days" {
  description = "Number of days before transitioning to STANDARD_IA storage class"
  type        = number
  default     = 30
}

variable "transition_glacier_ir_days" {
  description = "Number of days before transitioning to GLACIER_IR storage class"
  type        = number
  default     = 90
}

variable "noncurrent_versions_to_keep" {
  description = "Number of noncurrent versions to retain"
  type        = number
  default     = 10
}

variable "abort_multipart_days" {
  description = "Number of days before aborting incomplete multipart uploads"
  type        = number
  default     = 7
}

variable "expire_delete_markers" {
  description = "Whether to expire delete markers"
  type        = bool
  default     = true
}
