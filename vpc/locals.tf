locals {
  name_prefix = var.name != "" ? var.name : "${var.app_name}-${var.app_namespace}-${var.tfenv}"

  base_tags = {
    Environment = var.tfenv
    Terraform   = "true"
    Namespace   = var.app_namespace
    Department  = var.department
    Product     = var.app_name
  }

  base_cidr = var.vpc_subnet_configuration.autogenerate ? format(var.vpc_subnet_configuration.base_cidr, random_integer.cidr_vpc[0].result) : var.vpc_subnet_configuration.base_cidr

  nat_gateway_configuration = var.nat_gateway_custom_configuration.enabled ? {
    enable_nat_gateway                 = var.nat_gateway_custom_configuration.enable_nat_gateway
    enable_dns_hostnames               = var.nat_gateway_custom_configuration.enable_dns_hostnames
    single_nat_gateway                 = var.nat_gateway_custom_configuration.single_nat_gateway
    one_nat_gateway_per_az             = var.nat_gateway_custom_configuration.one_nat_gateway_per_az
    reuse_nat_ips                      = var.elastic_ip_custom_configuration.enabled ? var.elastic_ip_custom_configuration.reuse_nat_ips : false
    external_nat_ip_ids                = var.elastic_ip_custom_configuration.enabled ? var.elastic_ip_custom_configuration.external_nat_ip_ids : []
    enable_vpn_gateway                 = var.nat_gateway_custom_configuration.enable_vpn_gateway
    propagate_public_route_tables_vgw  = var.nat_gateway_custom_configuration.enable_vpn_gateway
    propagate_private_route_tables_vgw = var.nat_gateway_custom_configuration.propagate_private_route_tables_vgw
    } : {
    enable_nat_gateway                 = true
    enable_dns_hostnames               = true
    single_nat_gateway                 = var.tfenv == "prod" ? false : true
    one_nat_gateway_per_az             = false
    reuse_nat_ips                      = var.elastic_ip_custom_configuration.enabled ? var.elastic_ip_custom_configuration.reuse_nat_ips : false
    external_nat_ip_ids                = var.elastic_ip_custom_configuration.enabled ? var.elastic_ip_custom_configuration.external_nat_ip_ids : []
    enable_vpn_gateway                 = false
    propagate_public_route_tables_vgw  = false
    propagate_private_route_tables_vgw = false
  }

  # domains = concat(
  #   try(var.root_domain.create, false) ? [] : [var.root_domain.name],
  #   coalesce(var.root_domain.additional_domains, [])
  # )
}
