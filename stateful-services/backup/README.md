# terraform-aws-infrastructure: Stateful Services: AWS BACKUP

Forked from https://github.com/lgallard/terraform-aws-backup

Terraform module to create AWS Backup plans. AWS Backup is a fully managed backup service that makes it easy to centralize and automate the back up of data across AWS services (EBS volumes, RDS databases, DynamoDB tables, EFS file systems, and Storage Gateway volumes).

## Usage

You can use this module to create a simple plan using the module's `rule_*` variables. You can also  use the `rules` and `selections` list of maps variables to build a more complete plan by defining several rules and selections at once.

Check the [examples](examples/) for the **simple plan**, **complete plan**, **simple plan using variables** and the **selection by tags plan** snippets.

### Example (complete plan)

This example creates a plan with two rules and two selections at once. It also defines a vault key which is used by the first rule because no `target_vault_name` was given (null). Whereas the second rule is using the "Default" vault key.

The first selection has two assignments, the first defined by a resource ARN and the second one defined by a tag condition. The second selection has just one assignment defined by a resource ARN.

```terraform
module "aws_backup_example" {

  source = "aaronforce1/terraform-aws-infrastructure//stateful-services/backup"

  # Vault
  vault_name = "vault-3"

  # Plan
  plan_name = "complete-plan"

  # Notifications
  notifications = {
    sns_topic_arn       = aws_sns_topic.backup_vault_notifications.arn
    backup_vault_events = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
  }

  # Multiple rules using a list of maps
  rules = [
    {
      name                     = "rule-1"
      schedule                 = "cron(0 12 * * ? *)"
      target_vault_name        = null
      start_window             = 120
      completion_window        = 360
      enable_continuous_backup = true
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 30
      },
      copy_actions = [
        {
          lifecycle = {
            cold_storage_after = 0
            delete_after       = 90
          },
          destination_vault_arn = "arn:aws:backup:us-west-2:123456789101:backup-vault:Default"
        },
      ]
      recovery_point_tags = {
        Environment = "production"
      }
    },
    {
      name                = "rule-2"
      schedule            = "cron(0 7 * * ? *)"
      target_vault_name   = "Default"
      schedule            = null
      start_window        = 120
      completion_window   = 360
      lifecycle           = {}
      copy_action         = {}
      recovery_point_tags = {}
    },
  ]

  # Multiple selections
  #  - Selection-1: By resources and tag
  #  - Selection-2: Only by resources
  #  - Selection-3: By resources and conditions
  selections = [
    {
      name      = "selection-1"
      resources     = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table1"]
      not_resources = []
      selection_tags = [
        {
          type  = "STRINGEQUALS"
          key   = "Environment"
          value = "production"
        },
        {
          type  = "STRINGEQUALS"
          key   = "Owner"
          value = "production"
        }
      ]
    },
    {
      name      = "selection-2"
      resources = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table2"]
    },
    {
      name          = "selection-3"
      resources     = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table3"]
      not_resources = []
      conditions = {
        string_equals = [
          {
            key   = "aws:ResourceTag/Component"
            value = "rds"
          }
          ,
          {
            key   = "aws:ResourceTag/Project"
            value = "Project1"
          }
        ]
        string_like = [
          {
            key   = "aws:ResourceTag/Application"
            value = "app*"
          }
        ]
        string_not_equals = [
          {
            key   = "aws:ResourceTag/Backup"
            value = "false"
          }
        ]
        string_not_like = [
          {
            key   = "aws:ResourceTag/Environment"
            value = "test*"
          }
        ]
      }
    }
  ]

  tags = {
    Owner       = "backup team"
    Environment = "production"
    Terraform   = true
  }
}

```

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.25 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.ab_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_report_plan.ab_report](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_report_plan) | resource |
| [aws_backup_selection.ab_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.ab_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_lock_configuration.ab_vault_lock_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration) | resource |
| [aws_backup_vault_notifications.backup_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_notifications) | resource |
| [aws_iam_policy.ab_tag_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ab_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ab_backup_s3_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ab_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ab_restores_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ab_restores_s3_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ab_tag_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sns_topic_policy.backup_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_iam_policy_document.ab_role_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ab_tag_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.backup_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | (Infrastructure) Application Name | `string` | `"aws-backup"` | no |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | (Infrastructure) Application Namespace | `string` | n/a | yes |
| <a name="input_changeable_for_days"></a> [changeable\_for\_days](#input\_changeable\_for\_days) | The number of days before the lock date. If omitted creates a vault lock in governance mode, otherwise it will create a vault lock in compliance mode | `number` | `null` | no |
| <a name="input_department"></a> [department](#input\_department) | (Infrastructure) Application Billing Department, aka Cost Center; responsible for this provisioning | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name, e.g. alpha, beta | `string` | n/a | yes |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | If configured, the module will attach this role to selections, instead of creating IAM resources by itself | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Allow to set IAM role name, otherwise use predefined default | `string` | `""` | no |
| <a name="input_locked"></a> [locked](#input\_locked) | Change to true to add a lock configuration for the backup vault | `bool` | `false` | no |
| <a name="input_max_retention_days"></a> [max\_retention\_days](#input\_max\_retention\_days) | The maximum retention period that the vault retains its recovery points | `number` | `null` | no |
| <a name="input_min_retention_days"></a> [min\_retention\_days](#input\_min\_retention\_days) | The minimum retention period that the vault retains its recovery points | `number` | `null` | no |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | Notification block which defines backup vault events and the SNS Topic ARN to send AWS Backup notifications to. Leave it empty to disable notifications | `any` | `{}` | no |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | The display name of a backup plan | `string` | `null` | no |
| <a name="input_reports"></a> [reports](#input\_reports) | The default cache behavior for this distribution. | <pre>list(object({<br>    name               = string<br>    description        = optional(string, null)<br>    formats            = optional(list(string), null)<br>    s3_bucket_name     = string<br>    s3_key_prefix      = optional(string, null)<br>    report_template    = string<br>    accounts           = optional(list(string), null)<br>    organization_units = optional(list(string), null)<br>    regions            = optional(list(string), null)<br>    framework_arns     = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| <a name="input_rule_completion_window"></a> [rule\_completion\_window](#input\_rule\_completion\_window) | The amount of time AWS Backup attempts a backup before canceling the job and returning an error | `number` | `null` | no |
| <a name="input_rule_copy_action_destination_vault_arn"></a> [rule\_copy\_action\_destination\_vault\_arn](#input\_rule\_copy\_action\_destination\_vault\_arn) | An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup. | `string` | `null` | no |
| <a name="input_rule_copy_action_lifecycle"></a> [rule\_copy\_action\_lifecycle](#input\_rule\_copy\_action\_lifecycle) | The lifecycle defines when a protected resource is copied over to a backup vault and when it expires. | `map(any)` | `{}` | no |
| <a name="input_rule_enable_continuous_backup"></a> [rule\_enable\_continuous\_backup](#input\_rule\_enable\_continuous\_backup) | Enable continuous backups for supported resources. | `bool` | `false` | no |
| <a name="input_rule_lifecycle_cold_storage_after"></a> [rule\_lifecycle\_cold\_storage\_after](#input\_rule\_lifecycle\_cold\_storage\_after) | Specifies the number of days after creation that a recovery point is moved to cold storage | `number` | `null` | no |
| <a name="input_rule_lifecycle_delete_after"></a> [rule\_lifecycle\_delete\_after](#input\_rule\_lifecycle\_delete\_after) | Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after` | `number` | `null` | no |
| <a name="input_rule_name"></a> [rule\_name](#input\_rule\_name) | An display name for a backup rule | `string` | `null` | no |
| <a name="input_rule_recovery_point_tags"></a> [rule\_recovery\_point\_tags](#input\_rule\_recovery\_point\_tags) | Metadata that you can assign to help organize the resources that you create | `map(string)` | `{}` | no |
| <a name="input_rule_schedule"></a> [rule\_schedule](#input\_rule\_schedule) | A CRON expression specifying when AWS Backup initiates a backup job | `string` | `null` | no |
| <a name="input_rule_start_window"></a> [rule\_start\_window](#input\_rule\_start\_window) | The amount of time in minutes before beginning a backup | `number` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | A list of rule maps | `any` | `[]` | no |
| <a name="input_selection_conditions"></a> [selection\_conditions](#input\_selection\_conditions) | A map of conditions that you define to assign resources to your backup plans using tags. | `map(any)` | `{}` | no |
| <a name="input_selection_name"></a> [selection\_name](#input\_selection\_name) | The display name of a resource selection document | `string` | `null` | no |
| <a name="input_selection_not_resources"></a> [selection\_not\_resources](#input\_selection\_not\_resources) | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to exclude from a backup plan. | `list(any)` | `[]` | no |
| <a name="input_selection_resources"></a> [selection\_resources](#input\_selection\_resources) | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan | `list(any)` | `[]` | no |
| <a name="input_selection_tags"></a> [selection\_tags](#input\_selection\_tags) | List of tags for `selection_name` var, when using variable definition. | `list(any)` | `[]` | no |
| <a name="input_selections"></a> [selections](#input\_selections) | A list of selction maps | `any` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_vault_force_destroy"></a> [vault\_force\_destroy](#input\_vault\_force\_destroy) | A boolean that indicates that all recovery points stored in the vault are deleted so that the vault can be destroyed without error. | `bool` | `false` | no |
| <a name="input_vault_kms_key_arn"></a> [vault\_kms\_key\_arn](#input\_vault\_kms\_key\_arn) | The server-side encryption key that is used to protect your backups | `string` | `null` | no |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | Name of the backup vault to create. If not given, AWS use default | `string` | `null` | no |
| <a name="input_windows_vss_backup"></a> [windows\_vss\_backup](#input\_windows\_vss\_backup) | Enable Windows VSS backup option and create a VSS Windows backup | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_plan_arn"></a> [plan\_arn](#output\_plan\_arn) | The ARN of the backup plan |
| <a name="output_plan_id"></a> [plan\_id](#output\_plan\_id) | The id of the backup plan |
| <a name="output_plan_role"></a> [plan\_role](#output\_plan\_role) | The service role of the backup plan |
| <a name="output_plan_version"></a> [plan\_version](#output\_plan\_version) | Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan |
| <a name="output_vault_arn"></a> [vault\_arn](#output\_vault\_arn) | The ARN of the vault |
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | The name of the vault |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
