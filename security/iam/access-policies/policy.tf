locals {
  policies = flatten([
    for role in var.role_policies : [
      for policy in roles : {
        name = policy.name
        description = policy.description
        path = lookup(policy, path, "/")
        policy = policy.policy
      }
    ]
  ])
}

resource "aws_iam_policy" "policy" {
  for_each = {
    for policy in local.policies: policy.name => policy 
  }

  name        = policy.name
  path        = policy.path
  description = policy.description

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(policy.policy)

  tags = local.base_tags
}