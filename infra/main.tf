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