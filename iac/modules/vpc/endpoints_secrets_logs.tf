# Uses the same SG created in endpoints.tf (aws_security_group.endpoints)
# and the same private/data subnet alread defined in vpc.tf (var.private_subnets)

# Secrets Manager VPC Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
    vpc_id             = aws_vpc.this.id
    service_name       = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
    vpc_endpoint_type  = "Interface"
    subnet_ids        = local.vpce_subnet_ids
    security_group_ids = [aws_security_group.endpoints.id]
    private_dns_enabled = true

    tags = merge({
        Name        = "${var.name_prefix}-secretsmanager-endpoint"
        Project     = var.project
        Environment = var.environment
        Owner       = var.owner
        CostCenter  = var.cost_center
        Compliance  = var.compliance
        Backup      = var.backup
    }, var.extra_tags)
}

# CloudWatch Logs VPC Endpoint
resource "aws_vpc_endpoint" "logs" {
    vpc_id             = aws_vpc.this.id
    service_name       = "com.amazonaws.${data.aws_region.current.name}.logs"
    vpc_endpoint_type  = "Interface"
    subnet_ids        = local.vpce_subnet_ids
    security_group_ids = [aws_security_group.endpoints.id]
    private_dns_enabled = true

    tags = merge({
        Name        = "${var.name_prefix}-logs-endpoint"
        Project     = var.project
        Environment = var.environment
        Owner       = var.owner
        CostCenter  = var.cost_center
        Compliance  = var.compliance
        Backup      = var.backup
    }, var.extra_tags)
}
