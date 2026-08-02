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

  allowed_source_address_prefixes = ["103.175.135.241/32"]
}

module "bytebrain_subnet" {
  source              = "./modules/subnet"
  resource_group_name = module.bytebrain_rg.name
  vnet_name           = module.bytebrain_vnet.name
  subnet_name         = "bytebrain-app"
  address_prefixes    = ["10.0.1.64/26"]
  tags                = local.bytebrain_tags
}

module "nat_gateway" {
  source              = "./modules/nat-gateway"
  resource_group_name = module.bytebrain_rg.name
  location            = module.bytebrain_rg.location
  nat_gateway_name    = "natgw-bytebrain"
  public_ip_name      = "pip-natgw-bytebrain"
  subnet_id           = module.bytebrain_subnet.subnet_id
  tags                = local.bytebrain_tags
}

module "key_vault" {
  source              = "./modules/key-vault"
  resource_group_name = module.bytebrain_rg.name
  location            = module.bytebrain_rg.location
  key_vault_name      = "kvdpkdev01"
  tags                = local.bytebrain_tags
}

module "bytebrain_ssh_key_secret" {
  source       = "./modules/key-vault-secret"
  key_vault_id = module.key_vault.key_vault_id
  secret_name  = "bytebrain-ssh-public-key"
  secret_value = var.ssh_public_key
}

module "bytebrain_db_connection_string" {
  source       = "./modules/key-vault-secret"
  key_vault_id = module.key_vault.key_vault_id
  secret_name  = "bytebrain-db-connection-string"
  secret_value = var.db_connection_string
}

module "bytebrain_jwt_secret" {
  source       = "./modules/key-vault-secret"
  key_vault_id = module.key_vault.key_vault_id
  secret_name  = "bytebrain-jwt-secret"
  secret_value = var.jwt_secret
}

data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "bytebrain-ssh-public-key"
  key_vault_id = module.key_vault.key_vault_id
  depends_on   = [module.bytebrain_ssh_key_secret]
}


# module "bytebrain_app_vm" {
#   source                = "./modules/app-vm"
#   resource_group_name   = module.bytebrain_rg.name
#   location              = module.bytebrain_rg.location
#   vm_name               = "bytebrain-app-01"
#   subnet_id             = module.bytebrain_subnet.subnet_id
#   bastion_subnet_prefix = "10.0.1.0/26"
#   vm_size               = "Standard_D2s_v5"
#   admin_username        = var.admin_username
#   ssh_public_key        = data.azurerm_key_vault_secret.ssh_public_key.value
#   identity = {
#     type = "SystemAssigned"
#   }
#   tags                  = local.bytebrain_tags
# }

module "bytebrain_lb" {
  source                     = "./modules/load-balancer"
  resource_group_name        = module.bytebrain_rg.name
  location                   = module.bytebrain_rg.location
  lb_name                    = "lb-bytebrain-app"
  public_ip_name             = "pip-lb-bytebrain"
  # backend_nic_id             = module.bytebrain_app_vm.nic_id
  # backend_nic_ip_config_name = "internal"
  tags                       = local.bytebrain_tags
}

resource "azurerm_shared_image_gallery" "bytebrain" {
  name                = "bytebrain_gallery"
  resource_group_name = module.bytebrain_rg.name
  location            = module.bytebrain_rg.location
  tags                = local.bytebrain_tags
}

resource "azurerm_shared_image" "bytebrain_app" {
  name                = "bytebrain-app-image"
  gallery_name        = azurerm_shared_image_gallery.bytebrain.name
  resource_group_name = module.bytebrain_rg.name
  location            = module.bytebrain_rg.location
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "ByteBrain"
    offer     = "app"
    sku       = "linux"
  }
}

data "azurerm_shared_image_version" "bytebrain_app" {
  name                = "3.0.0"
  image_name          = azurerm_shared_image.bytebrain_app.name
  gallery_name        = azurerm_shared_image_gallery.bytebrain.name
  resource_group_name = module.bytebrain_rg.name
}

module "bytebrain_vmss" {
  source                 = "./modules/vmss"
  resource_group_name    = module.bytebrain_rg.name
  location                = module.bytebrain_rg.location
  vmss_name               = "vmss-bytebrain-app"
  subnet_id               = module.bytebrain_subnet.subnet_id
  gallery_image_id        = data.azurerm_shared_image_version.bytebrain_app.id
  vm_size                  = "Standard_D2s_v5"
  instance_count            = 1
  admin_username            = var.admin_username
  ssh_public_key            = data.azurerm_key_vault_secret.ssh_public_key.value
  bastion_subnet_prefix     = "10.0.1.0/26"
  backend_pool_id           = module.bytebrain_lb.backend_pool_id
  health_probe_id           = module.bytebrain_lb.health_probe_id
  key_vault_name            = module.key_vault.key_vault_name
  default_instances         = 1
  min_instances             = 1
  max_instances             = 2
  tags                      = local.bytebrain_tags
}