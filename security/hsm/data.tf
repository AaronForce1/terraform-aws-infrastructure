data "aws_availability_zones" "available" {}

data "aws_subnet" "hsm_subnet_selections" {
  count = length(var.subnet_ids)

  id = var.hsm.subnet_ids[count.index]
}

