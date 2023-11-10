resource "random_integer" "cidr_vpc" {
  count = var.vpc_subnet_configuration.autogenerate ? 1 : 0
  min   = 0
  max   = 255
  keepers = {
    name = "eks-${var.app_namespace}-${var.tfenv}-cluster-vpc"
  }
}

module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = local.base_cidr
  networks = flatten([
    ## TODO: Auto-sort so the big bits are handled first?
    for network in var.vpc_subnet_configuration.subnet_bit_interval : [
      for i in range(0, network.count) : {
        name     = "${network.name}-${i}"
        new_bits = network.new_bits
      }
    ]
  ])
}