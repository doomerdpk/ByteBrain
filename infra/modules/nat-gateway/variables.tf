variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "nat_gateway_name" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}