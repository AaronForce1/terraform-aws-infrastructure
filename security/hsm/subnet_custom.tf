resource "aws_subnet" "cloudhsm_v2_subnets" {
  for_each = {
    for idx in range(0, var.hsm.create_custom_subnet ? length(lookup(var.hsm, "custom_subnet_cidrs", 1)) : 0) : "hsm-private-subnet-${idx}" => idx
  }

  vpc_id = var.vpc_id

  ## TODO: Autognerate cidr blocks if possible
  cidr_block = element(var.hsm.custom_subnet_cidrs, each.value)

  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, each.value)

  tags = merge({
    Name = "hsm-private-subnet-${each.value}"
  }, local.base_tags)
}