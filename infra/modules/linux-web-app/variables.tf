variable "name" {
  description = "App Service name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for Web App"
  type        = string
}

variable "location" {
  description = "Azure region for Web App"
  type        = string
}

variable "app_service_plan_id" {
  description = "App Service plan ID for the Web App"
  type        = string
}

variable "container_image" {
  description = "Docker image reference to deploy to the Web App"
  type        = string
}

variable "app_settings" {
  description = "App settings for the Web App"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the Web App"
  type        = map(string)
  default     = {}
}
