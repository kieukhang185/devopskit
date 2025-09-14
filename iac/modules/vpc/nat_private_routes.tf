# Elactic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = merge({
    Name        = "${var.name_prefix}-eip-nat-${each.key}"
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = var.backup
    Tier        = "public"
    Service     = "networking"
  }, var.extra_tags)
}

# NAT Gateways in public subnets
resource "aws_nat_gateway" "this" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  depends_on    = [aws_internet_gateway.igw]
  tags = merge({
    Name        = "${var.name_prefix}-nat-${each.key}"
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = var.backup
    Tier        = "private"
    Service     = "networking"
  }, var.extra_tags)
}

# Private route tables (one per AZ)
resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.this
  vpc_id   = aws_vpc.this.id
  tags = merge({
    Name        = "${var.name_prefix}-private-rt-${each.key}"
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = var.backup
    Tier        = "private"
    Service     = "networking"
  }, var.extra_tags)
}

# Route to NAT Gateway for private subnets
resource "aws_route" "private_default" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

# Associate private route tables with private subnets
resource "aws_route_table_association" "private_assoc" {
  for_each = {
    for k, s in aws_subnet.private : k => {
      rt_id = aws_route_table.private[k].id
      id    = s.id
    }
  }
  subnet_id      = each.value.id
  route_table_id = each.value.rt_id
}

# Associate private route tables with data subnets
resource "aws_route_table_association" "data_assoc" {
  for_each = {
    for k, s in aws_subnet.data : k => {
      rt_id = aws_route_table.private[k].id
      id    = s.id
    }
  }
  subnet_id      = each.value.id
  route_table_id = each.value.rt_id
}
