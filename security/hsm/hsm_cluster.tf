resource "aws_cloudhsm_v2_cluster" "cloudhsm_v2_cluster" {
  hsm_type   = var.hsm.hsm_type != null ? var.hsm.hsm_type : "hsm1.medium"
  subnet_ids = local.subnet_ids

  tags = merge({
    Name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-cluster"
  }, local.base_tags)
}