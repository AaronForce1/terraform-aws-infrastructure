module "secrets_manager" {
  source   = "terraform-aws-modules/secrets-manager/aws"
  version  = "1.1.1"
  for_each = var.secrets

  name          = coalesce(each.value.name, each.key)
  description   = try(each.value.description, null)
  secret_string = try(each.value.value, null)
  kms_key_id    = try(each.value.key_id, null)

  tags = merge(try(each.value.tags, {}), local.base_tags)
}
