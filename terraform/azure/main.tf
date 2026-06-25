data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "platform" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.azure_location
  tags     = local.tags
}


resource "azurerm_key_vault" "platform" {
  name                       = "${var.azure_name_prefix}${var.environment}kv"
  location                   = azurerm_resource_group.platform.location
  resource_group_name        = azurerm_resource_group.platform.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  rbac_authorization_enabled = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "terraform_kv_secrets" {
  scope                = azurerm_key_vault.platform.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.terraform_sp_object_id
}


resource "azurerm_storage_account" "audit" {
  name                     = "${var.azure_name_prefix}${var.environment}audit"
  resource_group_name      = azurerm_resource_group.platform.name
  location                 = azurerm_resource_group.platform.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = false

  network_rules {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = 30
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_storage_container" "audit" {
  name                  = "audit-logs"
  storage_account_id    = azurerm_storage_account.audit.id
  container_access_type = "private"
}

resource "azurerm_monitor_diagnostic_setting" "storage_audit" {
  name                       = "${var.project}-${var.environment}-storage-diag"
  target_resource_id         = azurerm_storage_account.audit.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }
}


resource "azurerm_virtual_network" "this" {
  name                = "${var.project}-${var.environment}-vnet"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space       = var.vnet_address_space
  tags                = local.tags
}

resource "azurerm_subnet" "private" {
  name                 = "private"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space[0], 4, 0)]
}

resource "azurerm_network_security_group" "private" {
  name                = "${var.project}-${var.environment}-private-nsg"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "deny_inbound_internet" {
  name                        = "DenyInboundInternet"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.platform.name
  network_security_group_name = azurerm_network_security_group.private.name
}

resource "azurerm_network_security_rule" "allow_https_internal" {
  name                        = "AllowHTTPSInternal"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.vnet_address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.platform.name
  network_security_group_name = azurerm_network_security_group.private.name
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

resource "azurerm_network_watcher" "this" {
  name                = "${var.project}-${var.environment}-nw"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  tags                = local.tags
}

resource "azurerm_network_watcher_flow_log" "vnet" {
  network_watcher_name = azurerm_network_watcher.this.name
  resource_group_name  = azurerm_resource_group.platform.name
  name                 = "${var.project}-${var.environment}-flowlog"

  target_resource_id = azurerm_virtual_network.this.id
  storage_account_id = azurerm_storage_account.audit.id
  enabled            = true

  retention_policy {
    enabled = true
    days    = var.log_retention_days
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.platform.workspace_id
    workspace_region      = var.azure_location
    workspace_resource_id = azurerm_log_analytics_workspace.platform.id
    interval_in_minutes   = 10
  }
}


resource "azurerm_log_analytics_workspace" "platform" {
  name                = "${var.project}-${var.environment}-law"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}

resource "azurerm_security_center_subscription_pricing" "defender" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "defender_storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_contact" "security" {
  name                = "Security Contact"
  email               = var.security_contact_email
  phone               = "+10000000000"
  alert_notifications = true
  alerts_to_admins    = true
}


resource "azurerm_subscription_policy_assignment" "storage_https" {
  name                 = "${var.project}-${var.environment}-storage-https"
  subscription_id      = "/subscriptions/${var.azure_subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c6381-a422-445a-9271-5890516005cd"
  display_name         = "Secure transfer required for storage accounts"
}

resource "azurerm_subscription_policy_assignment" "storage_public" {
  name                 = "${var.project}-${var.environment}-no-public-blob"
  subscription_id      = "/subscriptions/${var.azure_subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1c6e92c9-99f0-4e55-84cf-897b72ebfbb6"
  display_name         = "Storage accounts should prevent public access"
}
