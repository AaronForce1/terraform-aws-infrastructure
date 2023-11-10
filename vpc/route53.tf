## TODO: ADD COMPATIBILITY FOR PRIVATE EKS CLUSTERS
resource "aws_route53_zone" "hosted_zone" {
  count = try(var.root_domain.create ? 1 : 0, 0)
  name  = var.root_domain.name
}