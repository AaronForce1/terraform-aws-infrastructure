# terraform-aws-infrastructure: Stateful Services: RDS

Currently defaults to postgres14. _Optimisation still in progress._

# Documentation

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.25 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.26.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | ~> 6.3 |
| <a name="module_rds_sg"></a> [rds\_sg](#module\_rds\_sg) | terraform-aws-modules/security-group/aws | >= 4.9.0 |

## Resources

| Name | Type |
|------|------|
| [aws_db_subnet_group.subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | (Infrastructure) Application Name | `string` | `"rds"` | no |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | (Infrastructure) Application Namespace | `string` | n/a | yes |
| <a name="input_department"></a> [department](#input\_department) | (Infrastructure) Application Billing Department, aka Cost Center; responsible for this provisioning | `string` | n/a | yes |
| <a name="input_rds"></a> [rds](#input\_rds) | Config to create rds | <pre>object({<br>    rds_name                               = string<br>    instance_class                         = string<br>    port                                   = number<br>    allocated_storage                      = number<br>    max_allocated_storage                  = number<br>    storage_type                           = string<br>    db_name                                = string<br>    username                               = string<br>    backup_retention_period                = number<br>    cloudwatch_log_group_retention_in_days = number<br>    apply_immediately                      = bool<br>    auto_minor_version_upgrade             = bool<br>    skip_final_snapshot                    = bool<br>    deletion_protection                    = bool<br>    multi_az                               = bool<br>    create_load_balancer                   = bool<br>    engine_version                         = string<br>    engine                                 = string<br>    family                                 = string<br>    major_engine_version                   = string<br>    enabled_cloudwatch_logs_exports        = list(string)<br>    additional_ingress_with_cidr_blocks = list(object({<br>      from_port   = number<br>      to_port     = number<br>      protocol    = string<br>      description = string<br>      cidr_blocks = string<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_rds_default_allowed_ingress"></a> [rds\_default\_allowed\_ingress](#input\_rds\_default\_allowed\_ingress) | CIDR for rds allowed access; defaults to 0.0.0.0/0 | `string` | `"0.0.0.0/0"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs to be used for rds subnet group | `list(string)` | `[]` | no |
| <a name="input_tfenv"></a> [tfenv](#input\_tfenv) | (Infrastructure) Environment | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to provision rds | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | RDS Provisioned Endpoint |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->