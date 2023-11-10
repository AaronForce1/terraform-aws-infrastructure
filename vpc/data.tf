# data "aws_route53_zone" "cluster_domains" {
#   for_each = {
#     for domain in local.domains : domain => domain
#   }
#   name = each.value
# }
