locals {
  prefix = "${var.system_id}-${var.service_type}${var.index}"
}

# -- VPC
resource "aws_vpc" "main" {
  ipv4_ipam_pool_id    = var.ipam_pool_id
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.prefix}-vpc"
  }
}

# -- Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 1, 1)

  tags = {
    Name = "${local.prefix}-subnet-private"
  }
}

resource "aws_subnet" "transit" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 1, 0)

  tags = {
    Name = "${local.prefix}-subnet-transit"
  }
}

# -- Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "transit" {
  vpc_id             = aws_vpc.main.id
  subnet_ids         = [aws_subnet.transit.id]
  transit_gateway_id = var.transit_gateway_id
}

# -- Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }

  tags = {
    Name = "${local.prefix}-rtb-private"
  }

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit
  ]
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "transit" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-rtb-transit"
  }
}

resource "aws_route_table_association" "transit" {
  subnet_id      = aws_subnet.transit.id
  route_table_id = aws_route_table.transit.id
}

# -- Network Interface
resource "aws_network_interface" "test" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.test.id]

  tags = {
    Name = "${local.prefix}-eni-test"
  }
}

resource "aws_security_group" "test" {
  name   = "allow_all"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}