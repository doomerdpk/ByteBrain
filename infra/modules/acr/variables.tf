variable "name" {
  description = "Globally unique ACR name (alphanumeric only, 5-50 chars, no hyphens)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy the ACR into"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku" {
  description = "ACR SKU — Basic, Standard, or Premium. Premium required for geo-replication, private endpoints, retention policy, network rules"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed (set false + use private endpoint for production)"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "CIDR ranges allowed through the network rule set (Premium only)"
  type        = list(string)
  default     = []
}

variable "untagged_retention_days" {
  description = "Days to retain untagged manifests before purge (Premium only)"
  type        = number
  default     = 7
}

variable "georeplication_locations" {
  description = "Additional Azure regions to geo-replicate the registry to (Premium only)"
  type        = list(string)
  default     = []
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy for the primary registry location (Premium only)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the registry"
  type        = map(string)
  default     = {}
}