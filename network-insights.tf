resource "aws_ec2_network_insights_path" "to_internet" {
  count = var.workload_count

  source         = module.workload_vpc[count.index].network_interface_id
  destination    = aws_internet_gateway.internet.id
  destination_ip = "8.8.8.8"
  protocol       = "tcp"

  tags = {
    Name = "workload${count.index}-to-internet"
  }
}

resource "aws_ec2_network_insights_path" "from_internet" {
  count = var.workload_count

  source      = aws_nat_gateway.internet.network_interface_id # インターネットゲートウェイからだと分析に失敗するのでNATゲートウェイで代用
  destination = module.workload_vpc[count.index].network_interface_id
  protocol    = "tcp"

  tags = {
    Name = "workload${count.index}-from-internet"
  }
}

resource "aws_ec2_network_insights_path" "to_common_service" {
  count = var.workload_count

  source      = module.workload_vpc[count.index].network_interface_id
  destination = module.common_service_vpc.network_interface_id
  protocol    = "tcp"

  tags = {
    Name = "workload${count.index}-to-common-service"
  }
}

resource "aws_ec2_network_insights_path" "from_common_service" {
  count = var.workload_count

  source      = module.common_service_vpc.network_interface_id
  destination = module.workload_vpc[count.index].network_interface_id
  protocol    = "tcp"

  tags = {
    Name = "workload${count.index}-from-common-service"
  }
}

resource "aws_ec2_network_insights_path" "inter_workloads" {
  for_each = { for it in setproduct(range(var.workload_count), range(var.workload_count)) : join(",", it) => it if it[0] != it[1] }

  source      = module.workload_vpc[each.value[0]].network_interface_id
  destination = module.workload_vpc[each.value[1]].network_interface_id
  protocol    = "tcp"

  tags = {
    Name = "workload${each.value[0]}-to-workload${each.value[1]}"
  }
}