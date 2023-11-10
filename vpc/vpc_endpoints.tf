module "vpc-endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.1"

  vpc_id = module.vpc.vpc_id
  security_group_ids = [
    # module.eks.cluster_primary_security_group_id,
    # module.eks.cluster_security_group_id,
    # module.eks.worker_security_group_id
    # module.eks.node_security_group_id
  ]

  endpoints = {
    s3 = {
      service = "s3"
      tags = merge({
        "Name" = "${local.name_prefix}-s3-vpc-endpoint"
      }, local.base_tags)
    }
  }
}

resource "aws_vpc_endpoint" "rds" {
  lifecycle { ignore_changes = [dns_entry] }
  vpc_id = module.vpc.vpc_id

  service_name        = "com.amazonaws.${var.aws_region}.rds"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    # module.eks.cluster_primary_security_group_id,
    # module.eks.cluster_security_group_id,
    # module.eks.worker_security_group_id
    # module.eks.node_security_group_id
  ]

  tags = merge({
    Name                                         = "${local.name_prefix}-rds-endpoint"
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
  }, local.base_tags)

  subnet_ids = flatten(module.vpc.private_subnets)
}