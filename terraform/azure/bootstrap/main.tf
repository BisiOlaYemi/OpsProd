terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

variable "azure_subscription_id" { type = string }
variable "azure_location" {
  type    = string
  default = "eastus"
}
variable "azure_name_prefix" { type = string }
variable "environment" { type = string }

resource "azurerm_resource_group" "state" {
  name     = "${var.azure_name_prefix}-${var.environment}-tfstate-rg"
  location = var.azure_location
}

resource "azurerm_storage_account" "state" {
  name                     = "${var.azure_name_prefix}${var.environment}tf"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  network_rules {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  blob_properties {
    versioning_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

output "state_resource_group" {
  value = azurerm_resource_group.state.name
}

output "state_storage_account" {
  value = azurerm_storage_account.state.name
}

output "state_container" {
  value = azurerm_storage_container.state.name
}
