# ################################################################################
# # RDS Subnet
# ################################################################################

resource "aws_db_subnet_group" "subnet_group" {
  name       = var.rds.name
  subnet_ids = var.subnet_ids
  tags = merge(
    local.base_tags,
    {
      Name = "${var.rds.name}-subnet-group"
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
  name        = var.rds.name
  description = "Security group for ${var.app_namespace} rds"
  vpc_id      = var.vpc_id
  ingress_with_cidr_blocks = concat([
    for ingress in var.rds.rds_default_allowed_ingress :
    {
      from_port   = var.rds.port
      to_port     = var.rds.port
      protocol    = "tcp"
      description = "Default RDS Allowed Ingress"
      cidr_blocks = ingress
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
      Name = "${var.rds.name}-sg"
    }
  )
}

# ################################################################################
# # RDS Module
# ################################################################################

module "rds-cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~>9.2"

  ## General Config
  name           = var.rds.name
  engine         = coalesce(var.rds.engine, "aurora-postgresql")
  engine_version = coalesce(var.rds.engine_version, "14.5")
  instance_class = coalesce(var.rds.instance_class, "db.r6g.large")
  port           = var.rds.port

  ## TODO: Expand Compatibility for more instances
  instances = {
    one = {}
  }

  ## Networking
  vpc_id               = var.vpc_id
  db_subnet_group_name = aws_db_subnet_group.subnet_group.id
  security_group_rules = {
    ex1_ingress = {
      source_security_group_id = module.rds_sg.security_group_id
    }
    rds_default_allowed_ingress = {
      cidr_blocks = var.rds.rds_default_allowed_ingress
    }
  }

  ## Storage
  storage_encrypted = true

  ## Authentication
  iam_database_authentication_enabled                    = true
  database_name                                          = var.rds.db_name
  master_username                                        = var.rds.username
  manage_master_user_password                            = true
  manage_master_user_password_rotation                   = true
  master_user_password_rotation_automatically_after_days = 7
  master_user_secret_kms_key_id                          = var.rds.kms_key_id

  ## Parameter Groups
  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = var.rds.name
  db_cluster_parameter_group_family      = coalesce(var.rds.family, "aurora-postgresql14")
  db_cluster_parameter_group_description = "${var.rds.name} cluster parameter group"

  ## TODO: Customisable in the future with defaults
  db_cluster_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
      }, {
      name         = "rds.force_ssl"
      value        = 1
      apply_method = "immediate"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = var.rds.name
  db_parameter_group_family      = coalesce(var.rds.family, "aurora-postgresql14")
  db_parameter_group_description = "${var.rds.name} example DB parameter group"

  ## TODO: Customisable in the future with defaults
  db_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
    }
  ]

  ## Logging
  enabled_cloudwatch_logs_exports        = coalesce(var.rds.enabled_cloudwatch_logs_exports, ["postgresql"])
  create_cloudwatch_log_group            = true
  monitoring_interval                    = 10
  cloudwatch_log_group_retention_in_days = var.rds.cloudwatch_log_group_retention_in_days

  create_db_cluster_activity_stream     = true
  db_cluster_activity_stream_kms_key_id = var.rds.kms_key_id
  db_cluster_activity_stream_mode       = "async"

  # Maintenance and upgrade
  apply_immediately          = var.rds.apply_immediately
  auto_minor_version_upgrade = var.rds.auto_minor_version_upgrade
  skip_final_snapshot        = var.rds.skip_final_snapshot
  deletion_protection        = var.rds.deletion_protection
  backup_retention_period    = var.rds.backup_retention_period
  copy_tags_to_snapshot      = true

  publicly_accessible = false

  tags = local.base_tags
}