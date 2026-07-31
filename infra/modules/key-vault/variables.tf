variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "object_id" {
  type        = string
  description = "Object ID of the identity (user/SP) allowed to manage secrets"
}

variable "tags" {
  type    = map(string)
  default = {}
}