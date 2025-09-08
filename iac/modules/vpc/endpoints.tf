
data "aws_region" "current" {}

resource "aws_security_group" "endpoints" {
  name        = "${var.name_prefix}-vpce-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow HTTPS traffic from within the VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({
    Name        = "${var.name_prefix}-vpce-sg"
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = var.backup
  }, var.extra_tags)
}

# Required for SSM: ssm, ssmmessages, ec2messages
locals {
    ssm_services = toset(["ssm", "ssmmessages", "ec2messages"])
    # Place endpoints in both private and data subnets
    vpce_subnet_ids = concat(
        [for k, s in aws_subnet.private : s.id],
        [for k, s in aws_subnet.data    : s.id]
    )
}

resource "aws_vpc_endpoint" "ssm" {
  for_each            = local.ssm_services
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.vpce_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge({
    Name        = "${var.name_prefix}-vpce-${each.key}"
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = var.backup
  }, var.extra_tags)
}
