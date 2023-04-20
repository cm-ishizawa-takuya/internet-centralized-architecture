# -- VPC
resource "aws_vpc" "internet" {
  ipv4_ipam_pool_id    = aws_vpc_ipam_pool.infrastructure.id
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.system_id}-internet-vpc"
  }

  depends_on = [
    aws_vpc_ipam_pool_cidr.infrastructure
  ]
}

# -- Subnet
resource "aws_subnet" "internet_public" {
  vpc_id                  = aws_vpc.internet.id
  cidr_block              = cidrsubnet(aws_vpc.internet.cidr_block, 1, 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.system_id}-internet-subnet-public"
  }
}

resource "aws_subnet" "internet_transit" {
  vpc_id     = aws_vpc.internet.id
  cidr_block = cidrsubnet(aws_vpc.internet.cidr_block, 1, 0)

  tags = {
    Name = "${var.system_id}-internet-subnet-transit"
  }
}

# -- Internet Gateway
resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.internet.id

  tags = {
    Name = "${var.system_id}-internet-igw"
  }
}

# -- Nat Gateway
resource "aws_nat_gateway" "internet" {
  allocation_id = aws_eip.internet.id
  subnet_id     = aws_subnet.internet_public.id

  tags = {
    Name = "${var.system_id}-internet-ngw"
  }

  depends_on = [
    aws_internet_gateway.internet
  ]
}

resource "aws_eip" "internet" {
  tags = {
    Name = "${var.system_id}-internet-ngw-eip"
  }

  depends_on = [
    aws_internet_gateway.internet
  ]
}

# -- Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "internet" {
  transit_gateway_id                              = aws_ec2_transit_gateway.main.id
  vpc_id                                          = aws_vpc.internet.id
  subnet_ids                                      = [aws_subnet.internet_transit.id]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

# -- Route Table
resource "aws_route_table" "internet_public" {
  vpc_id = aws_vpc.internet.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet.id
  }

  route {
    cidr_block         = var.toplevel_pool_cidr
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${var.system_id}-internet-rtb-public"
  }

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.internet
  ]
}

resource "aws_route_table_association" "internet_public" {
  subnet_id      = aws_subnet.internet_public.id
  route_table_id = aws_route_table.internet_public.id
}

resource "aws_route_table" "internet_transit" {
  vpc_id = aws_vpc.internet.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.internet.id
  }

  tags = {
    Name = "${var.system_id}-internet-rtb-transit"
  }
}

resource "aws_route_table_association" "internet_transit" {
  subnet_id      = aws_subnet.internet_transit.id
  route_table_id = aws_route_table.internet_transit.id
}