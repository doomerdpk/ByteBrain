variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "bastion_subnet_prefix" {
  type        = string
  description = "Address prefix of bastion subnet"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "os_disk_size_gb" {
  type    = number
  default = 30
}

variable "enable_accelerated_networking" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}