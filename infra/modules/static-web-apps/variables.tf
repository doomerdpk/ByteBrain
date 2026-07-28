variable "name" {
  description = "The name of the Azure Static Web App."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Azure Static Web App will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the Azure Static Web App will be deployed."
  type        = string
}

variable "sku_tier" {
  description = "The pricing tier of the Azure Static Web App. Valid values are Free and Standard."
  type        = string
  default     = "Standard"
}

variable "sku_size" {
  description = "The SKU size of the Azure Static Web App. Valid values are Free and Standard. This should match the selected SKU tier."
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "A map of tags to assign to the Azure Static Web App."
  type        = map(string)
  default     = {}
}