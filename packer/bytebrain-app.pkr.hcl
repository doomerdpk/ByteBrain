packer {
  required_plugins {
    azure = {
      version = ">= 2.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "subscription_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "image_version" {
  type = string
}

variable "gallery_name" {
  type = string
}

variable "gallery_image_name" {
  type = string
}

source "azure-arm" "bytebrain" {
  use_azure_cli_auth = true
  subscription_id    = var.subscription_id

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts-gen2"

  location = "South India"
  vm_size  = "Standard_D2s_v5"

  build_resource_group_name              = var.resource_group_name  
  virtual_network_name                   = var.vnet_name
  virtual_network_subnet_name            = var.subnet_name
  virtual_network_resource_group_name    = var.resource_group_name
  private_virtual_network_with_public_ip = false

  ssh_username = "packer"

  shared_image_gallery_destination {
    subscription         = var.subscription_id
    resource_group        = var.resource_group_name
    gallery_name           = var.gallery_name
    image_name             = var.gallery_image_name
    image_version           = var.image_version
    replication_regions     = ["South India"]
  }

  managed_image_resource_group_name = var.resource_group_name
  managed_image_name                = "bytebrain-app-image-${var.image_version}"
}

build {
  sources = ["source.azure-arm.bytebrain"]

  provisioner "shell" {
    script = "scripts/install-dependencies.sh"
  }

  provisioner "shell" {
    script = "scripts/deploy-app.sh"
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }
}