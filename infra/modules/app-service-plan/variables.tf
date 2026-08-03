variable "name" {
  description = "App Service plan name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for App Service plan"
  type        = string
}

variable "location" {
  description = "Azure region for App Service plan"
  type        = string
}

variable "sku_name" {
  description = "SKU tier for App Service plan"
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Tags to apply to the App Service plan"
  type        = map(string)
  default     = {}
}
