variable "system_id" {}
variable "toplevel_pool_cidr" {}
variable "workload_count" { type = number }
variable "group" { type = list(list(number)) }