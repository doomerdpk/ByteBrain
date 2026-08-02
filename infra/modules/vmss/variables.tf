variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vmss_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "gallery_image_id" {
  type        = string
  description = "Resource ID of the Compute Gallery image version to deploy"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1ms"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "bastion_subnet_prefix" {
  type = string
}

variable "backend_pool_id" {
  type        = string
  description = "Load Balancer backend pool ID to associate with this VMSS"
}

variable "health_probe_id" {
  type        = string
  description = "LB health probe ID, required for rolling upgrades to track instance health"
}

variable "tags" {
  type    = map(string)
  default = {}
}