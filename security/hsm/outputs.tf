output "hsm_cluster" {
  value = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster
}

output "hsm" {
  value = aws_cloudhsm_v2_hsm.hsm
}