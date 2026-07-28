variable "resource_group_name" {
  type = string
}

variable "fd_name" {
  type        = string
  default     = "bytebrain-frontdoor"
  description = "Front Door name"
}

variable "origin_host_name" {
  description = "The hostname of the Storage Account static website endpoint."
  type        = string
}

variable "front_door_sku" {
  type    = string
  default = "Standard_AzureFrontDoor"

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.front_door_sku)
    error_message = "front_door_sku must be Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}