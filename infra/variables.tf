variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-bytebrain-prod-westindia"
}

variable "location" {
  description = "Azure Region for the resource group"
  type        = string
  default     = "West India"
}