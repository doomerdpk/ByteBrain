locals {
  bytebrain_tags = {
    Project     = "Bytebrain"
    ManagedBy   = "Terraform"
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
  location            = "East Asia"

  tags = local.bytebrain_tags
}

module "vnet" {
  source = "./modules/vnet"

  name                = "vnet-bytebrain-dev-centralindia"
  resource_group_name      = module.bytebrain_rg.name
  location                 = module.bytebrain_rg.location

  address_space = [
    "10.0.0.0/16"
  ]

  tags = local.bytebrain_tags
}