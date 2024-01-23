# terraform-aws-infrastructure: Stateful Services: S3-Cloudfront Static Site

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.33.0 |
| <a name="provider_aws.us-east-1"></a> [aws.us-east-1](#provider\_aws.us-east-1) | 5.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 4.3 |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | terraform-aws-modules/cloudfront/aws | ~> 3.2 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.11 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket_policy.attach_s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_acm_certificate.my_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_cloudfront_cache_policy.default_cache_behavior_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_cache_policy.ordered_cache_behavior_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Terraform app name, e.g. terraform-aws-infrastructure | `string` | `"aws-infrastructure"` | no |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | App Name for the AWS Infrastructure being provisioned: | `string` | `""` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region for all primary configurations | `string` | n/a | yes |
| <a name="input_aws_secondary_region"></a> [aws\_secondary\_region](#input\_aws\_secondary\_region) | Secondary Region for certain redundant AWS components | `string` | `"us-east-1"` | no |
| <a name="input_cloudfront_distributions"></a> [cloudfront\_distributions](#input\_cloudfront\_distributions) | Configure to create distribution in cloudfront | <pre>list(object({<br>    origins = list(object({<br>      domain_name = string,<br>      origin_id   = string,<br>      custom_origin_config = object({<br>        http_port              = optional(number),<br>        https_port             = optional(number),<br>        origin_protocol_policy = string,<br>        origin_ssl_protocols   = list(string)<br>    }) }))<br>    aliases            = list(string)<br>    price_class        = string<br>    certificate_domain = string<br>    default_cache_behavior = object({<br>      allowed_methods   = list(string)<br>      cached_methods    = list(string)<br>      target_origin_id  = string<br>      cache_policy_name = string<br>      min_ttl           = number<br>      default_ttl       = number<br>      max_ttl           = number<br>      compress          = bool<br>    })<br>    ordered_cache_behavior = list(object({<br>      path_pattern      = string<br>      allowed_methods   = list(string)<br>      cached_methods    = list(string)<br>      target_origin_id  = string<br>      cache_policy_name = string<br>      min_ttl           = number<br>      default_ttl       = number<br>      max_ttl           = number<br>      compress          = bool<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name, e.g. alpha, beta | `string` | n/a | yes |
| <a name="input_route53"></a> [route53](#input\_route53) | Configure to create hosted zone, IAM policy, and attach policy to application IAM role | <pre>object({<br>    domain                 = optional(string)       # Hosted zone domain<br>    create                 = optional(bool)         # True to Create route53 hostedzone<br>    roles_to_attach_policy = optional(list(string)) # List of IAM role to attach the hosted zone policy to<br>    root_domain            = optional(string)       # Root hosted zone domain<br>  })</pre> | `{}` | no |
| <a name="input_s3"></a> [s3](#input\_s3) | s3 bucket for hosting static website | <pre>list(object({<br>    enabled       = bool<br>    name          = string<br>    website       = optional(any)<br>    attach_policy = bool<br>    cloudfront = object({<br>      enabled = bool<br>      domain  = optional(string)<br>      zone    = optional(string)<br>    })<br>  }))</pre> | <pre>[<br>  {<br>    "attach_policy": false,<br>    "cloudfront": {<br>      "enabled": false<br>    },<br>    "enabled": false,<br>    "name": ""<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_ids"></a> [s3\_bucket\_ids](#output\_s3\_bucket\_ids) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->