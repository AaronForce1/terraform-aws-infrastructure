# variable "environment" {}
variable "app_namespace" {
  description = "App Name for the AWS Infrastructure being provisioned:"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name, e.g. alpha, beta"
  type        = string
}

variable "app_name" {
  description = "Terraform app name, e.g. terraform-aws-infrastructure"
  type        = string
  default     = "aws-infrastructure"
}

variable "route53" {
  description = "Configure to create hosted zone, IAM policy, and attach policy to application IAM role"
  type = object({
    domain                 = optional(string)       # Hosted zone domain
    create                 = optional(bool)         # True to Create route53 hostedzone
    roles_to_attach_policy = optional(list(string)) # List of IAM role to attach the hosted zone policy to
    root_domain            = optional(string)       # Root hosted zone domain
  })
  default = {}
}

variable "cloudfront_distributions" {
  description = "Configure to create distribution in cloudfront"
  type = list(object({
    origins = list(object({
      domain_name = string,
      origin_id   = string,
      custom_origin_config = object({
        http_port              = optional(number),
        https_port             = optional(number),
        origin_protocol_policy = string,
        origin_ssl_protocols   = list(string)
    }) }))
    aliases            = list(string)
    price_class        = string
    certificate_domain = string
    default_cache_behavior = object({
      allowed_methods   = list(string)
      cached_methods    = list(string)
      target_origin_id  = string
      cache_policy_name = string
      min_ttl           = number
      default_ttl       = number
      max_ttl           = number
      compress          = bool
    })
    ordered_cache_behavior = list(object({
      path_pattern      = string
      allowed_methods   = list(string)
      cached_methods    = list(string)
      target_origin_id  = string
      cache_policy_name = string
      min_ttl           = number
      default_ttl       = number
      max_ttl           = number
      compress          = bool
    }))
  }))
  default = []
}

# tflint-ignore: terraform_unused_declarations
variable "aws_region" {
  type        = string
  description = "AWS Region for all primary configurations"
}

# tflint-ignore: terraform_unused_declarations
variable "aws_secondary_region" {
  type        = string
  description = "Secondary Region for certain redundant AWS components"
  default     = "us-east-1"
}

# tflint-ignore: terraform_unused_declarations
variable "aws_profile" {
  type        = string
  description = "AWS Profile"
  default     = ""
}

variable "s3" {
  description = "s3 bucket for hosting static website"
  type = list(object({
    enabled       = bool
    name          = string
    website       = optional(any)
    attach_policy = bool
    cloudfront = object({
      enabled = bool
      domain  = optional(string)
      zone    = optional(string)
    })
  }))
  default = [{
    enabled       = false
    name          = ""
    attach_policy = false
    cloudfront = {
      enabled = false
    }
  }]
}