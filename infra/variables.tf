variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-bytebrain-dev-centralindia"
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
  default     = "Central India"
}

variable "acr_name" {
  description = "Globally unique ACR name (letters/numbers only, no hyphens, 5-50 chars)"
  type        = string
  default     = "acrbytebraindev01"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM admin access"
  sensitive   = true
}

variable "admin_username" {
  type        = string
  description = "Admin username for VM SSH access"
}