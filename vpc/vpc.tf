data "aws_availability_zones" "available_azs" {
  state = "available"
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-vpc"
  cidr = local.base_cidr
  azs  = data.aws_availability_zones.available_azs.names

  private_subnets = [
    for network in module.subnet_addrs.networks : network.cidr_block
    if strcontains(network.name, "private")
  ]
  public_subnets = [
    for network in module.subnet_addrs.networks : network.cidr_block
    if strcontains(network.name, "public")
  ]
  database_subnets = [
    for network in module.subnet_addrs.networks : network.cidr_block
    if strcontains(network.name, "database")
  ]
  intra_subnets = [
    for network in module.subnet_addrs.networks : network.cidr_block
    if strcontains(network.name, "intra")
  ]
  intra_dedicated_network_acl = true

  customer_gateways  = var.customer_gateways
  enable_vpn_gateway = var.customer_gateways != {} ? true : false
  # NAT Gateway settings + EIPs
  enable_nat_gateway                 = local.nat_gateway_configuration.enable_nat_gateway
  enable_dns_hostnames               = local.nat_gateway_configuration.enable_dns_hostnames
  single_nat_gateway                 = local.nat_gateway_configuration.single_nat_gateway
  one_nat_gateway_per_az             = local.nat_gateway_configuration.one_nat_gateway_per_az
  reuse_nat_ips                      = local.nat_gateway_configuration.reuse_nat_ips
  external_nat_ip_ids                = local.nat_gateway_configuration.external_nat_ip_ids
  propagate_public_route_tables_vgw  = local.nat_gateway_configuration.propagate_public_route_tables_vgw
  propagate_private_route_tables_vgw = local.nat_gateway_configuration.propagate_private_route_tables_vgw
  manage_default_network_acl         = false

  public_dedicated_network_acl = true
  public_inbound_acl_rules     = var.public_inbound_acl_rules
  public_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]

  private_dedicated_network_acl = true
  private_inbound_acl_rules     = var.private_inbound_acl_rules
  private_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]

  database_dedicated_network_acl = true
  database_inbound_acl_rules     = var.database_inbound_acl_rules
  database_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = local.base_cidr
    }
  ]


  # Manage Default VPC
  manage_default_vpc = false

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = false
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = coalesce(var.vpc_flow_logs.enabled, var.tfenv == "prod" ? true : false)
  create_flow_log_cloudwatch_log_group = coalesce(var.vpc_flow_logs.enabled, var.tfenv == "prod" ? true : false)
  create_flow_log_cloudwatch_iam_role  = coalesce(var.vpc_flow_logs.enabled, var.tfenv == "prod" ? true : false)
  flow_log_max_aggregation_interval    = 60

  tags = merge({
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
  }, local.base_tags)

  nat_gateway_tags = local.base_tags

  vpc_tags = merge({
    Name = "${local.name_prefix}-vpc"
  }, local.base_tags)

  public_subnet_tags = merge({
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
    "kubernetes.io/role/elb"                     = "1"
    "SubnetType"                                 = "public"
  }, local.base_tags)

  private_subnet_tags = merge({
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
    "kubernetes.io/role/internal-elb"            = "1"
    "SubnetType"                                 = "private"
  }, local.base_tags)

  database_subnet_tags = merge({
    "SubnetType" = "db-private"
  }, local.base_tags)
}
