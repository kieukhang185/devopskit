# Create a CodeStar Connections connection for various Git providers
locals {
  # Enforce minimal tagging policy (extend as needed)
  base_tags = {
    Service    = "ci"
    Owner      = "khangkieu"
    CostCenter = "vtd-devops-khangkieu"
    Compliance = "internal"
    Project    = "devopskit"
  }

  tags = merge(local.base_tags, var.tags)
}

resource "aws_codestarconnections_connection" "this" {
  name          = var.name
  provider_type = var.provider_type

  # host_arn required only for on-prem GHES/Bitbucket Server
  #   dynamic "host_arn" {
  #     for_each = var.host_arn == null ? [] : [var.host_arn]
  #     content  = host_arn.value
  #   }

  tags = local.tags
}
