variable "resource_group_name" {
  type        = string
  description = "Resource group where the storage account will be created"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique name for the storage account (lowercase, no hyphens, 3-24 chars)"
}

variable "account_replication_type" {
  type        = string
  description = "Replication type for the storage account"
  default     = "LRS"
}

variable "index_document" {
  type        = string
  description = "Default document served at root"
  default     = "index.html"
}

variable "error_404_document" {
  type        = string
  description = "SPA fallback document for unmatched routes"
  default     = "index.html"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}