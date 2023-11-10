## GLOBAL VAR CONFIGURATION
variable "aws_region" {
  type        = string
  description = "AWS Region for all primary configurations"
}

variable "root_domain" {
  description = "Domain root where all systems are orchestrating control"
  type = object({
    create             = bool
    name               = string
    ingress_records    = optional(list(string))
    additional_domains = optional(list(string))
  })
}

variable "app_name" {
  type        = string
  description = "(Infrastructure) Application Name"
  default     = "ec2"
}

variable "app_namespace" {
  type        = string
  description = "(Infrastructure) Application Namespace"
}

variable "tfenv" {
  type        = string
  description = "(Infrastructure) Environment"
}

variable "department" {
  type        = string
  description = "(Infrastructure) Application Billing Department, aka Cost Center; responsible for this provisioning"
}

variable "name" {
  type        = string
  description = "Optional override for name instead of standard {app_name}-{app_namespace}-{tfenv}"
  default     = ""
}

variable "vpc_flow_logs" {
  description = "Manually enable or disable VPC flow logs; Please note, for production, these are enabled by default otherwise they will be disabled; setting a value for this object will override all defaults regardless of environment"
  type = object({
    enabled = optional(bool)
  })
  default = {}
}

variable "elastic_ip_custom_configuration" {
  description = "By default, this module will provision new Elastic IPs for the VPC's NAT Gateways; however, one can also override and specify separate, pre-existing elastic IPs as needed in order to preserve IPs that are whitelisted; reminder that the list of EIPs should have the same count as nat gateways created."
  type = object({
    enabled             = bool
    reuse_nat_ips       = optional(bool)
    external_nat_ip_ids = optional(list(string))
  })
  default = {
    enabled             = false
    external_nat_ip_ids = []
    reuse_nat_ips       = false
  }
}

variable "nat_gateway_custom_configuration" {
  description = "Override the default NAT Gateway configuration, which configures a single NAT gateway for non-prod, while one per AZ on tfenv=prod"
  type = object({
    enabled                            = bool
    enable_nat_gateway                 = bool
    enable_dns_hostnames               = bool
    single_nat_gateway                 = bool
    one_nat_gateway_per_az             = bool
    enable_vpn_gateway                 = bool
    propagate_public_route_tables_vgw  = bool
    propagate_private_route_tables_vgw = bool
  })
  default = {
    enable_dns_hostnames               = true
    enable_nat_gateway                 = true
    enable_vpn_gateway                 = false
    enabled                            = false
    one_nat_gateway_per_az             = true
    propagate_public_route_tables_vgw  = false
    single_nat_gateway                 = false
    propagate_private_route_tables_vgw = false
  }
}

variable "vpc_subnet_configuration" {
  type = object({
    create_database_subnet = bool
    base_cidr              = string
    subnet_bit_interval = list(
      object({
        name     = string
        count    = number
        new_bits = number
      })
    )
    autogenerate = optional(bool)
  })
  description = "Configure VPC CIDR and relative subnet intervals for generating a VPC. If not specified, default values will be generated."
  default = {
    base_cidr = "172.%s.0.0/16"
    subnet_bit_interval = [
      {
        name     = "private"
        count    = 3
        new_bits = 2
      },
      {
        name     = "intra"
        count    = 2
        new_bits = 8
      },
      {
        name     = "public"
        count    = 2
        new_bits = 8
      },
      {
        name     = "database"
        count    = 0
        new_bits = 8
      }
    ]
    autogenerate           = true
    create_database_subnet = false
  }
}

variable "customer_gateways" {
  type    = any
  default = {}
}

variable "public_inbound_acl_rules" {
  type = list(map(string))
  default = [
    {
      "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1",
      "rule_action" : "allow", "rule_number" : 100, "to_port" : 0
    }
  ]
}
variable "private_inbound_acl_rules" {
  type = list(map(string))
  default = [
    {
      "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1",
      "rule_action" : "allow", "rule_number" : 100, "to_port" : 0
    }
  ]
}
variable "database_inbound_acl_rules" {
  type = list(map(string))
  default = [
    {
      "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1",
      "rule_action" : "allow", "rule_number" : 100, "to_port" : 0
    }
  ]
}
