data "aws_canonical_user_id" "current" {}
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.11"

  for_each = {
    for s3 in coalesce(var.s3, []) : s3.name => s3
    if s3.enabled
  }
  bucket        = each.value.name
  force_destroy = false
  website       = each.value.website
  # attach_policy = false       # will attach creation
  # policy        = data.aws_iam_policy_document.bucket_policy[each.value.name].json 

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  # acl    = "private"
  restrict_public_buckets  = true
  object_ownership         = "ObjectWriter"
  control_object_ownership = true

  cors_rule = [
    {
      allowed_headers = [
        "Authorization",
        "Content-Range",
        "Accept",
        "Content-Type",
        "Origin",
        "Range"
      ]
      allowed_methods = [
        "GET",
        "POST",
        "PUT"
      ]
      allowed_origins = [
        "*"
      ]
      expose_headers = [
        "Content-Range",
        "Content-Length",
        "ETag"
      ]
      max_age_seconds = 3000
    }
  ]
  owner = {
    id = data.aws_canonical_user_id.current.id
  }
  grant = [
    {
      type       = "CanonicalUser"
      permission = "FULL_CONTROL"
      id         = data.aws_canonical_user_id.current.id
    },
    {
      type       = "Group"
      permission = "READ_ACP"
      uri        = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
    {
      type       = "Group"
      permission = "READ"
      uri        = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    }
  ]

}

output "s3_bucket_ids" {
  value = {
    for name, bucket in module.s3_bucket : name => bucket.s3_bucket_id
  }
}

resource "aws_s3_bucket_policy" "attach_s3_bucket_policy" {
  for_each = {
    for s3 in coalesce(var.s3, []) : s3.name => s3
    if s3.attach_policy
  }
  bucket = each.value.name
  policy = data.aws_iam_policy_document.bucket_policy[each.value.name].json
}