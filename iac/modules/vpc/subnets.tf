# VPC Subnets Module
data "aws_availability_zones" "available" {
    state = "available"
}

locals {
    azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

    common_tags = {
        Environment = var.environment
        Owner       = var.owner
        Project     = var.project
        CostCenter  = var.cost_center
        Compliance  = var.compliance
        Backup      = var.backup
    }
}

# Public subnets
resource "aws_subnet" "public" {
    for_each = {
        for idx, az in local.azs : idx => {
            az = az
            cidr = var.public_subnet_cidrs[idx]
            idx = idx
        }
    }

    vpc_id            = var.vpc_id
    cidr_block       = each.value.cidr
    availability_zone = each.value.az
    map_public_ip_on_launch = true

    tags = merge(local.common_tags, {
        Name = "${var.project}-${var.environment}-public-${each.value.idx + 1}"
        Tier = "Public"
        Service = "networking"
    })
}

# Private subnets
resource "aws_subnet" "private" {
    for_each = {
        for idx, az in local.azs : idx => {
            az = az
            cidr = var.private_subnet_cidrs[idx]
            idx = idx
        }
    }
    vpc_id            = var.vpc_id
    cidr_block       = each.value.cidr
    availability_zone = each.value.az
    map_public_ip_on_launch = false

    tags = merge(local.common_tags, {
        Name = "${var.project}-${var.environment}-private-${each.value.idx + 1}"
        Tier = "Private"
        Service = "networking"
    })
}
