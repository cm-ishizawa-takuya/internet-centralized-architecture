output "network_interface_id" {
  value = aws_network_interface.test.id
}

output "transit_gateway_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.transit.id
}