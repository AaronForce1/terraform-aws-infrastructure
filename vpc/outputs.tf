## -----------
## MODULE: VPC
## -----------
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  value = {
    ipv4 = module.vpc.private_subnets_cidr_blocks
    ipv6 = module.vpc.private_subnets_ipv6_cidr_blocks
  }
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  value = {
    ipv4 = module.vpc.public_subnets_cidr_blocks
    ipv6 = module.vpc.public_subnets_ipv6_cidr_blocks
  }
}

output "db_subnets_cidr_blocks" {
  value = {
    ipv4 = module.vpc.database_subnets_cidr_blocks
    ipv6 = module.vpc.database_subnets_ipv6_cidr_blocks
  }
}

output "intra_subnets_cidr_blocks" {
  value = {
    ipv4 = module.vpc.intra_subnets_cidr_blocks
    ipv6 = module.vpc.intra_subnets_ipv6_cidr_blocks
  }
}

## -----------
## MODULE: subnet_addrs
## -----------

output "base_cidr_block" {
  value = module.vpc.vpc_cidr_block
}


###
### Check you are using proper region
###
output "name_prefix" {
  value = local.name_prefix
}

output "base_tags" {
  value = local.base_tags
}

output "route53_hosted_zone_id" {
  value = aws_route53_zone.hosted_zone[*].id
}

output "route53_hosted_zone_arns" {
  value = aws_route53_zone.hosted_zone[*].arn
}
