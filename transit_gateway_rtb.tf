# Route Table for Workload-VPCs
resource "aws_ec2_transit_gateway_route_table" "workload_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

resource "aws_ec2_transit_gateway_route" "to_internet" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload_vpc.id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet.id
}

resource "aws_ec2_transit_gateway_route" "block_inter_workloads" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload_vpc.id
  destination_cidr_block         = local.workload_pool_cidr
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route_table_association" "workload_vpc" {
  for_each = { for v in range(var.workload_count) : v => v }

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload_vpc.id
  transit_gateway_attachment_id  = module.workload_vpc[each.value].transit_gateway_attachment_id
}

# Route Table for Internet-VPC
resource "aws_ec2_transit_gateway_route_table" "internet_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "internet_vpc" {
  for_each = { for v in range(var.workload_count) : v => v }

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.internet_vpc.id
  transit_gateway_attachment_id  = module.workload_vpc[each.value].transit_gateway_attachment_id
}

resource "aws_ec2_transit_gateway_route_table_association" "internet_vpc" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.internet_vpc.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet.id
}