locals {
  bytebrain_tags = {
    Project   = "Bytebrain"
    ManagedBy = "Terraform"
  }
}

module "bytebrain_rg" {
  source = "./modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = local.bytebrain_tags
}

module "bytebrain_acr" {
  source = "./modules/acr"

  name                = var.acr_name
  resource_group_name = module.bytebrain_rg.name
  location            = var.location
  sku                 = "Standard"
  tags                = local.bytebrain_tags
}

# module "bytebrain_frontend" {
#   source = "./modules/storage-static-site"

#   resource_group_name      = module.bytebrain_rg.name
#   location                 = module.bytebrain_rg.location
#   storage_account_name     = "bytebrainfrontenddev01"
#   account_replication_type = "LRS"

#   tags = local.bytebrain_tags
# }

# module "bytebrain_front_door" {
#   source = "./modules/front-door"

#   resource_group_name = module.bytebrain_rg.name
#   fd_name             = "bytebrain-frontdoor"
#   origin_host_name      = module.bytebrain_frontend.primary_web_host
#   front_door_sku      = "Standard_AzureFrontDoor"

#   tags = local.bytebrain_tags
# }

module "bytebrain_frontend" {

  source = "./modules/static-web-apps"

  name                = "bytebrain-dev-fe"
  resource_group_name = module.bytebrain_rg.name
  # Static-web-apps are not available in all regions, so we will use East Asia for now.
  location = "East Asia"

  tags = local.bytebrain_tags
}

module "bytebrain_vnet" {
  source = "./modules/vnet"

  name                = "vnet-bytebrain-dev-centralindia"
  resource_group_name = module.bytebrain_rg.name
  location            = module.bytebrain_rg.location

  address_space = [
    "10.0.0.0/16"
  ]

  tags = local.bytebrain_tags
}

module "azure_bastion" {
  source = "./modules/azure-bastion"

  resource_group_name = module.bytebrain_rg.name
  location            = module.bytebrain_rg.location
  tags                = local.bytebrain_tags

  vnet_id   = module.bytebrain_vnet.id
  vnet_name = module.bytebrain_vnet.name

  bastion_subnet_address_prefix = "10.0.1.0/26"
  bastion_host_name             = "bastion-dev-01"

  sku                = "Basic"
  enable_diagnostics = false

  allowed_source_address_prefixes = ["203.0.113.0/24"]
}

module "bytebrain_subnet" {
  source              = "./modules/subnet"
  resource_group_name = module.bytebrain_rg.name
  vnet_name           = module.bytebrain_vnet.name
  subnet_name         = "bytebrain-app"
  address_prefixes    = ["10.0.1.0/24"]
  tags                = local.bytebrain_tags
}