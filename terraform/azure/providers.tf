provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

module "tags" {
  source = "../shared/modules/tags"

  environment = var.environment
  project     = var.project
  owner       = var.owner
}

locals {
  tags = module.tags.tags
}
