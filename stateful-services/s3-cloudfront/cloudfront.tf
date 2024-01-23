data "aws_cloudfront_cache_policy" "default_cache_behavior_policies" {
  for_each = toset([
    for distribution in var.cloudfront_distributions : distribution.default_cache_behavior.cache_policy_name
  ])

  name = each.value
}

locals {
  default_cache_behavior_policy_ids = {
    for name, policy in data.aws_cloudfront_cache_policy.default_cache_behavior_policies : name => policy.id
  }
}

data "aws_cloudfront_cache_policy" "ordered_cache_behavior_policies" {
  for_each = toset(flatten([
    for distribution in var.cloudfront_distributions : [
      for behavior in distribution.ordered_cache_behavior : behavior.cache_policy_name
    ]
  ]))

  name = each.value
}

locals {
  ordered_cache_behavior_policy_ids = {
    for name, policy in data.aws_cloudfront_cache_policy.ordered_cache_behavior_policies : name => policy.id
  }
}

data "aws_acm_certificate" "my_certificate" {
  provider = aws.us-east-1
  count    = length(var.cloudfront_distributions)

  domain   = var.cloudfront_distributions[count.index].certificate_domain
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  provider = aws.us-east-1
  count    = length(var.cloudfront_distributions)

  web_acl_id      = ""
  enabled         = true
  aliases         = var.cloudfront_distributions[count.index].aliases
  comment         = "CloudFront distribution"
  is_ipv6_enabled = true
  http_version    = "http2"
  price_class     = var.cloudfront_distributions[count.index].price_class

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.my_certificate[count.index].arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  #tfsec:ignore:AWS071

  dynamic "origin" {
    for_each = var.cloudfront_distributions[count.index].origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      custom_origin_config {
        http_port              = origin.value.custom_origin_config.http_port != null ? origin.value.custom_origin_config.http_port : 80
        https_port             = origin.value.custom_origin_config.https_port != null ? origin.value.custom_origin_config.https_port : 443
        origin_protocol_policy = origin.value.custom_origin_config.origin_protocol_policy
        origin_ssl_protocols   = origin.value.custom_origin_config.origin_ssl_protocols
      }
    }
  }
  default_cache_behavior {
    allowed_methods        = var.cloudfront_distributions[count.index].default_cache_behavior.allowed_methods
    cached_methods         = var.cloudfront_distributions[count.index].default_cache_behavior.cached_methods
    target_origin_id       = var.cloudfront_distributions[count.index].default_cache_behavior.target_origin_id
    cache_policy_id        = local.default_cache_behavior_policy_ids[var.cloudfront_distributions[count.index].default_cache_behavior.cache_policy_name]
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.cloudfront_distributions[count.index].default_cache_behavior.min_ttl
    default_ttl            = var.cloudfront_distributions[count.index].default_cache_behavior.default_ttl
    max_ttl                = var.cloudfront_distributions[count.index].default_cache_behavior.max_ttl
    compress               = var.cloudfront_distributions[count.index].default_cache_behavior.compress
  }
  dynamic "ordered_cache_behavior" {
    for_each = var.cloudfront_distributions[count.index].ordered_cache_behavior

    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      target_origin_id = ordered_cache_behavior.value.target_origin_id
      allowed_methods  = ordered_cache_behavior.value.allowed_methods
      cached_methods   = ordered_cache_behavior.value.cached_methods

      # cache_policy_id = data.aws_cloudfront_cache_policy.ordered_cache_policies[ordered_cache_behavior.cache_policy_name].id
      cache_policy_id        = local.ordered_cache_behavior_policy_ids[ordered_cache_behavior.value.cache_policy_name]
      viewer_protocol_policy = "redirect-to-https"
      compress               = ordered_cache_behavior.value.compress
      min_ttl                = ordered_cache_behavior.value.min_ttl
      default_ttl            = ordered_cache_behavior.value.default_ttl
      max_ttl                = ordered_cache_behavior.value.max_ttl
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.3"
  providers = {
    aws = aws.us-east-1
  }
  for_each = {
    for certificate in coalesce(var.s3, []) : "certificate-${certificate.name}" => certificate
    if certificate.cloudfront.enabled
  }

  domain_name               = each.value.cloudfront.domain
  zone_id                   = data.aws_route53_zone.zone[each.value.cloudfront.zone].id
  subject_alternative_names = []

  tags = {
    Name = "ACM certificate for ${each.value.name} S3 bucket"
  }
}

module "cloudfront" {
  for_each = {
    for cf in coalesce(var.s3, []) : cf.cloudfront.domain => cf
    if cf.cloudfront.enabled
  }
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 3.2"

  providers = {
    aws = aws.us-east-1
  }

  aliases = [
    each.value.cloudfront.domain
  ]

  comment             = "Cloudfront for ${each.value.cloudfront.domain}"
  enabled             = each.value.cloudfront.enabled
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false
  default_root_object = each.value.website.index_document

  origin_access_identities = {
    s3_bucket_access_identity = "Cloudfront Access Identity for ${each.value.cloudfront.domain}"
  }

  origin = {
    s3_bucket_access_identity = {
      domain_name           = module.s3_bucket[each.value.name].s3_bucket_bucket_regional_domain_name
      origin_access_control = each.value.cloudfront.domain
    }
  }

  create_origin_access_control = true

  origin_access_control = {
    (each.value.cloudfront.domain) = {
      description      = each.value.cloudfront.domain
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_bucket_access_identity"
    viewer_protocol_policy = "redirect-to-https"

    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = false

    use_forwarded_values = false
  }

  viewer_certificate = {
    acm_certificate_arn = module.acm["certificate-${each.value.name}"].acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "www" {
  for_each = {
    for record in coalesce(var.s3, []) : record.cloudfront.domain => record
    if record.cloudfront.enabled
  }
  zone_id = data.aws_route53_zone.zone[each.value.cloudfront.zone].zone_id
  name    = each.value.cloudfront.domain
  type    = "A"
  alias {
    name                   = module.cloudfront[each.value.cloudfront.domain].cloudfront_distribution_domain_name
    zone_id                = module.cloudfront[each.value.cloudfront.domain].cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
  depends_on = [
    module.cloudfront
  ]
}
