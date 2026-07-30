terraform {
  backend "azurerm" {
    resource_group_name  = "rg-bytebrain-tfstate-dev"
    storage_account_name = "dpkdev01"
    container_name       = "tfstate"
    key                  = "bytebrain.tfstate"
    use_azuread_auth     = true
  }
}