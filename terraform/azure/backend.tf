terraform {
  backend "azurerm" {
    resource_group_name  = "REPLACE_WITH_STATE_RG"
    storage_account_name = "REPLACE_WITH_STATE_SA"
    container_name       = "tfstate"
    key                  = "azure/secure-baseline.terraform.tfstate"
    use_azuread_auth     = true
  }
}
