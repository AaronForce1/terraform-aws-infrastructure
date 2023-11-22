## GLOBAL VAR CONFIGURATION
variable "app_name" {
  type        = string
  description = "(Infrastructure) Application Name"
  default     = "hsm"
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

variable "hsm" {
  description = "Config to create hsm"
  type = object({
    name                 = optional(string)
    hsm_type             = optional(string)
    hsm_count            = optional(number)
    subnet_ids           = optional(list(string))
    create_custom_subnet = optional(bool)
    custom_subnet_cidrs  = optional(list(string))
  })
  default = null
}

variable "subnet_ids" {
  description = "Subnet IDs to be used for hsm subnet group"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID to provision hsm"
  type        = string
}