data "aws_caller_identity" "current" {}

# WILL USE
data "aws_iam_policy_document" "bucket_policy" {
  for_each = {
    for policy_document in coalesce(var.s3, []) : policy_document.name => policy_document
    if policy_document.enabled
  }
  # policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    sid = "AllowCloudFrontServicePrincipal"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront[each.value.cloudfront.domain].cloudfront_distribution_arn] # to-do
    }

    resources = [
      "arn:aws:s3:::${each.value.name}/*",
    ]
  }
}

locals {
  route53_zones = distinct([for s3 in var.s3 : s3.cloudfront.zone if s3.cloudfront.zone != null])
}

data "aws_route53_zone" "zone" {
  for_each     = { for zone in local.route53_zones : zone => zone }
  name         = each.value
  private_zone = false
}
