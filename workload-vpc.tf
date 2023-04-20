module "workload_vpc" {
  count = var.workload_count

  source             = "./modules/workload-vpc"
  system_id          = var.system_id
  workload_index     = count.index
  availability_zone  = local.availability_zone
  ipam_pool_id       = aws_vpc_ipam_pool.workload.id
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_vpc_ipam_pool_cidr.workload
  ]
}