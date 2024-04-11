locals {
  base_tags = merge({
    Environment = var.environment
    Terraform   = "true"
    Namespace   = var.app_namespace
    Department  = var.department
    Product     = var.app_name
  }, var.tags)
}
