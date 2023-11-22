locals {
  name_prefix = "${var.app_name}-${var.app_namespace}-${var.tfenv}"
  base_tags = {
    Environment = var.tfenv
    Terraform   = "true"
    Namespace   = var.app_namespace
    Department  = var.department
    Product     = var.app_name
  }
  subnet_ids = concat(
    data.aws_subnet.hsm_subnet_selections[*].id,
    [for subnet in resource.aws_subnet.cloudhsm_v2_subnets : subnet.id]
  )
}