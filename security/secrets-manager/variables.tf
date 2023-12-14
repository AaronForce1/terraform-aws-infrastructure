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

variable "secrets" {
  type = map(object({
    name        = optional(string)
    value       = optional(string)
    description = optional(string)
    key_id      = optional(string)
    tags        = optional(map(string))
    # policy_configuration = optional(object({
    #   create_policy       = optional(bool)
    #   block_public_policy = optional(bool)
    #   policy_statements   = any
    # }))
  }))
  default = {}
}
