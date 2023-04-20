resource "aws_ec2_transit_gateway" "main" {
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  auto_accept_shared_attachments  = "enable"
  dns_support                     = "enable"

  tags = {
    Name = "${var.system_id}-tgw"
  }
}