locals {
  infrastructure_pool_cidr = cidrsubnet(var.toplevel_pool_cidr, 1, 0)
  workload_pool_cidr       = cidrsubnet(var.toplevel_pool_cidr, 1, 1)
}

resource "aws_vpc_ipam" "main" {
  operating_regions {
    region_name = local.region_name
  }

  tags = {
    Name = "${var.system_id}-ipam"
  }
}

resource "aws_vpc_ipam_pool" "toplevel" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.main.private_default_scope_id

  tags = {
    Name = "${var.system_id}-ipam-pool-toplevel"
  }
}

resource "aws_vpc_ipam_pool_cidr" "toplevel" {
  ipam_pool_id = aws_vpc_ipam_pool.toplevel.id
  cidr         = var.toplevel_pool_cidr
}

resource "aws_vpc_ipam_pool" "infrastructure" {
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  source_ipam_pool_id = aws_vpc_ipam_pool.toplevel.id
  locale              = local.region_name

  allocation_default_netmask_length = 24
  allocation_min_netmask_length     = 24
  allocation_max_netmask_length     = 24

  tags = {
    Name = "${var.system_id}-ipam-pool-infrastructure"
  }
}

resource "aws_vpc_ipam_pool_cidr" "infrastructure" {
  ipam_pool_id = aws_vpc_ipam_pool.infrastructure.id
  cidr         = local.infrastructure_pool_cidr
}

resource "aws_vpc_ipam_pool" "workload" {
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  source_ipam_pool_id = aws_vpc_ipam_pool.toplevel.id
  locale              = local.region_name

  allocation_default_netmask_length = 24
  allocation_min_netmask_length     = 24
  allocation_max_netmask_length     = 24

  tags = {
    Name = "${var.system_id}-ipam-pool-workload"
  }
}

resource "aws_vpc_ipam_pool_cidr" "workload" {
  ipam_pool_id = aws_vpc_ipam_pool.workload.id
  cidr         = local.workload_pool_cidr
}