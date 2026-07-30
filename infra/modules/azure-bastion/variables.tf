variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "vnet_id" {
  description = "Resource ID of the existing virtual network"
  type        = string
}

variable "vnet_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "bastion_subnet_address_prefix" {
  description = "Address prefix for AzureBastionSubnet (min /26 recommended)"
  type        = string
}

variable "bastion_host_name" {
  description = "Name of the Azure Bastion host"
  type        = string
}

variable "sku" {
  description = "Bastion SKU tier: Basic, Standard, or Premium"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "scale_units" {
  description = "Number of scale units (2-50, only valid for Standard/Premium SKU)"
  type        = number
  default     = 2

  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "scale_units must be between 2 and 50."
  }
}

variable "enable_tunneling" {
  description = "Enable native client support (SSH/RDP tunneling). Requires Standard or Premium SKU."
  type        = bool
  default     = false
}

variable "enable_ip_connect" {
  description = "Enable IP-based connection. Requires Standard or Premium SKU."
  type        = bool
  default     = false
}

variable "enable_shareable_link" {
  description = "Enable shareable link. Requires Standard or Premium SKU."
  type        = bool
  default     = false
}

variable "enable_kerberos" {
  description = "Enable Kerberos authentication. Requires Standard or Premium SKU."
  type        = bool
  default     = false
}

variable "enable_session_recording" {
  description = "Enable session recording. Requires Premium SKU only."
  type        = bool
  default     = false
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the Bastion host"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics (required if enable_diagnostics = true)"
  type        = string
  default     = null
}


variable "allowed_source_address_prefixes" {
  description = "Source address prefixes allowed inbound on 443 to the Bastion subnet"
  type        = list(string)
  default     = ["Internet"]
}