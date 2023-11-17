## GLOBAL VAR CONFIGURATION
variable "app_name" {
  type        = string
  description = "(Infrastructure) Application Name"
  default     = "rds"
}

variable "app_namespace" {
  type        = string
  description = "(Infrastructure) Application Namespace"
}

variable "tfenv" {
  type        = string
  description = "(Infrastructure) Environment"
}

variable "department" {
  type        = string
  description = "(Infrastructure) Application Billing Department, aka Cost Center; responsible for this provisioning"
}

variable "rds" {
  description = "Config to create rds"
  type = object({
    rds_name                               = string
    instance_class                         = string
    port                                   = number
    allocated_storage                      = number
    max_allocated_storage                  = number
    storage_type                           = string
    db_name                                = string
    username                               = string
    backup_retention_period                = number
    cloudwatch_log_group_retention_in_days = number
    apply_immediately                      = bool
    auto_minor_version_upgrade             = bool
    skip_final_snapshot                    = bool
    deletion_protection                    = bool
    multi_az                               = bool
    create_load_balancer                   = bool
    engine_version                         = string
    engine                                 = string
    family                                 = string
    major_engine_version                   = string
    enabled_cloudwatch_logs_exports        = list(string)
    additional_ingress_with_cidr_blocks = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      description = string
      cidr_blocks = string
    }))
  })
  default = null
}

variable "subnet_ids" {
  description = "Subnet IDs to be used for rds subnet group"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID to provision rds"
  type        = string
}

variable "rds_default_allowed_ingress" {
  description = "CIDR for rds allowed access; defaults to 0.0.0.0/0"
  type        = string
  default     = "0.0.0.0/0"
}