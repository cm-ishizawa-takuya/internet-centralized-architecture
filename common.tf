locals {
  region_name       = data.aws_region.current.name
  availability_zone = data.aws_availability_zones.available.names[0]
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}