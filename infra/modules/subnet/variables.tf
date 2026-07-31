variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "address_prefixes" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}