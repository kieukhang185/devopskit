variable "name" {
  description = "Display name for the CodeStar connection"
  type        = string
  default     = "devopskit-github-connection"
}

variable "provider_type" {
  description = "Provider type: GitHub | GitHubEnterpriseServer | Bitbucket | BitbucketServer"
  type        = string
  default     = "GitHub"
}

variable "host_arn" {
  description = "Host ARN for GitHub Enterprise Server or Bitbucket Server (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags (Environment, Service=ci, Owner, CostCenter, Compliance, Backup)"
  type        = map(string)
  default     = {}
}
