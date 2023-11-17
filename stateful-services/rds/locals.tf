locals {
  base_tags = {
    Environment = var.tfenv
    Terraform   = "true"
    Namespace   = var.app_namespace
    Department  = var.department
    Product     = var.app_name
  }
}