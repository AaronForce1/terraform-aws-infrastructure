resource "aws_cloudhsm_v2_hsm" "hsm" {
  for_each = {
    for idx in range(0, var.hsm.hsm_count != null ? var.hsm.hsm_count : 0) : "hsm-${var.app_namespace}-${var.tfenv}-${idx}" => idx
  }

  subnet_id  = local.subnet_ids[0]
  cluster_id = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_id
}