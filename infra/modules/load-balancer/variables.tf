variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "lb_name" {
  type = string
}

variable "public_ip_name" {
  type = string
}

# variable "backend_nic_id" {
#   type        = string
#   description = "Resource ID of the VM's NIC"
# }

# variable "backend_nic_ip_config_name" {
#   type        = string
#   default     = "internal"
#   description = "Name of the IP configuration on the VM's NIC (matches ip_configuration.name in app-vm module)"
# }

variable "health_probe_path" {
  type    = string
  default = "/api/v1/health"
}

variable "tags" {
  type    = map(string)
  default = {}
}