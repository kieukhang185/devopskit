# Create a public route table
# Single public route table for all public subnets
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.devopskit_vpc.id

    tags = merge({
        Name = "${var.name_prefix}-public-rt"
        Environment = var.environment
        Owner       = var.owner
        Project     = var.project
        CostCenter  = var.cost_center
        Compliance  = var.compliance
        Backup      = var.backup
    }, var.extra_tags)
}

resource "aws_route" "public_inet_v4" {
    route_table_id         = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
}

# Associate public route table with public subnets
resource "aws_route_table_association" "public" {
    for_each       = aws_subnet.public
    subnet_id      = each.value.id
    route_table_id = aws_route_table.public.id
}
