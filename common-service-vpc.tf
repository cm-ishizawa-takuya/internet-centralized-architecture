module "common_service_vpc" {
  source             = "./modules/private-vpc"
  system_id          = var.system_id
  service_type       = "common"
  index              = 0
  availability_zone  = local.availability_zone
  ipam_pool_id       = aws_vpc_ipam_pool.infrastructure.id
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_vpc_ipam_pool_cidr.workload
  ]
}