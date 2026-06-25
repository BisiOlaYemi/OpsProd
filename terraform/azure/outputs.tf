output "resource_group_name" {
  value = azurerm_resource_group.platform.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.platform.vault_uri
}

output "audit_storage_account_name" {
  value = azurerm_storage_account.audit.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.platform.id
}
