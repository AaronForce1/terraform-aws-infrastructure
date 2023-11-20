# ################################################################################
# # RDS Subnet
# ################################################################################

resource "aws_db_subnet_group" "subnet_group" {
  name       = var.rds.rds_name
  subnet_ids = var.subnet_ids
  tags = merge(
    local.base_tags,
    {
      Name = "${var.rds.rds_name}-subnet-group"
    }
  )
}


# ################################################################################
# # RDS Security Group
# ################################################################################

# default values
locals {
  additional_ingress_with_cidr_blocks = coalesce(var.rds.additional_ingress_with_cidr_blocks, [])
}

module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  version     = ">= 4.9.0"
  name        = var.rds.rds_name
  description = "Security group for ${var.app_namespace} rds"
  vpc_id      = var.vpc_id
  ingress_with_cidr_blocks = concat([
    {
      from_port   = var.rds.port
      to_port     = var.rds.port
      protocol    = "tcp"
      description = "Default RDS Allowed Ingress"
      cidr_blocks = var.rds_default_allowed_ingress
    }
  ], local.additional_ingress_with_cidr_blocks)
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = merge(
    local.base_tags,
    {
      Name = "${var.rds.rds_name}-sg"
    }
  )
}

# ################################################################################
# # RDS Module
# ################################################################################

module "rds" {
  source             = "terraform-aws-modules/rds/aws"
  version            = "~> 6.3"
  identifier         = var.rds.rds_name
  create_db_instance = true

  # General config
  engine               = coalesce(var.rds.engine, "postgres")
  engine_version       = var.rds.engine_version
  family               = coalesce(var.rds.family, "postgres14")
  major_engine_version = coalesce(var.rds.major_engine_version, "14")
  instance_class       = var.rds.instance_class
  port                 = var.rds.port

  # Storage
  allocated_storage     = var.rds.allocated_storage
  max_allocated_storage = var.rds.max_allocated_storage
  storage_type          = var.rds.storage_type
  storage_encrypted     = true
  iops                  = lookup(var.rds, "iops", null)
  kms_key_id            = lookup(var.rds, "kms_key_id", null)

  # Authentication
  iam_database_authentication_enabled = true
  db_name                             = var.rds.db_name
  username                            = var.rds.username
  manage_master_user_password         = true

  # Backup
  backup_retention_period = var.rds.backup_retention_period
  backup_window           = "03:00-06:00"

  # Log and monitoring
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = var.rds.cloudwatch_log_group_retention_in_days
  enabled_cloudwatch_logs_exports        = coalesce(var.rds.enabled_cloudwatch_logs_exports, ["postgresql", "upgrade"])
  performance_insights_enabled           = true
  performance_insights_retention_period  = 7
  create_monitoring_role                 = true
  monitoring_interval                    = 60
  monitoring_role_name                   = "${var.rds.rds_name}-monitoring-role"
  monitoring_role_description            = "Monitoring role for ${var.rds.rds_name}"

  # Maintenance and upgrade
  apply_immediately          = var.rds.apply_immediately
  auto_minor_version_upgrade = var.rds.auto_minor_version_upgrade
  maintenance_window         = "Mon:00:00-Mon:03:00"
  skip_final_snapshot        = var.rds.skip_final_snapshot
  deletion_protection        = var.rds.deletion_protection

  # Network and security
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.id
  vpc_security_group_ids = [module.rds_sg.security_group_id]
  multi_az               = var.rds.multi_az
  publicly_accessible    = false

  tags = local.base_tags
}