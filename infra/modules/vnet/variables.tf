variable "name" {
  description = "Name of the Virtual Network."
  type        = string

  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 64
    error_message = "The VNet name must be between 2 and 64 characters."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the VNet will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the Virtual Network will be deployed."
  type        = string
}

variable "address_space" {
  description = "List of address spaces that are used by the Virtual Network."
  type        = list(string)
}

variable "dns_servers" {
  description = "Optional list of custom DNS server IP addresses."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to associate with the Virtual Network."
  type        = map(string)
  default     = {}
}