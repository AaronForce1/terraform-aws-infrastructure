output "rds_endpoint" {
  description = "RDS Provisioned Endpoint"
  value       = module.rds-cluster.cluster_endpoint
}

output "rds_reader_endpoint" {
  description = "RDS Provisioned Reader Endpoint"
  value       = module.rds-cluster.cluster_reader_endpoint
}