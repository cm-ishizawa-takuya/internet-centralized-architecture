# Route Table for Workload-VPCs
resource "aws_ec2_transit_gateway_route_table" "workload_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

resource "aws_ec2_transit_gateway_route" "workload_vpc_to_internet" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload_vpc.id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet.id
}

resource "aws_ec2_transit_gateway_route" "block_inter_workloads" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload_vpc.id
  destination_cidr_block         = local.workload_pool_cidr
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route_table_propagation" "workload_vpc_to_common_service_vpc" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload_vpc.id
  transit_gateway_attachment_id  = module.common_service_vpc.transit_gateway_attachment_id
}

resource "aws_ec2_transit_gateway_route_table_association" "workload_vpc" {
  count = var.workload_count

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload_vpc.id
  transit_gateway_attachment_id  = module.workload_vpc[count.index].transit_gateway_attachment_id
}

# Route Table for Infrastructure-VPCs
resource "aws_ec2_transit_gateway_route_table" "infrastructure_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

resource "aws_ec2_transit_gateway_route" "infrastructure_vpc_to_internet" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.infrastructure_vpc.id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "infrastructure_vpc_to_workload_vpc" {
  count = var.workload_count

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.infrastructure_vpc.id
  transit_gateway_attachment_id  = module.workload_vpc[count.index].transit_gateway_attachment_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "internet_vpc_to_common_service_vpc" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.infrastructure_vpc.id
  transit_gateway_attachment_id  = module.common_service_vpc.transit_gateway_attachment_id
}

resource "aws_ec2_transit_gateway_route_table_association" "internet_vpc" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.infrastructure_vpc.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet.id
}

resource "aws_ec2_transit_gateway_route_table_association" "common_service_vpc" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.infrastructure_vpc.id
  transit_gateway_attachment_id  = module.common_service_vpc.transit_gateway_attachment_id
}