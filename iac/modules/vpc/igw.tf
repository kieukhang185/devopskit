# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name        = "${var.name_prefix}-igw"
    Environment = var.environment
    Owner       = var.owner
    Project     = var.project
    CostCenter  = var.cost_center
    Compliance  = var.compliance
    Backup      = var.backup
  }, var.extra_tags)
}
