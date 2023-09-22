# azurerm_storage_account outputs
output "azurerm_storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.this.id
}

# azurerm_storage_container outputs
output "azurerm_storage_container_id" {
  description = "The ID of the storage container"
  value       = azurerm_storage_container.this.id
}

# azurerm_key_vault outputs
output "azurerm_key_vault_id" {
  description = "The ID of the key vault"
  value       = azurerm_key_vault.this.id
}

# azurerm_key_vault_key outputs
output "azurerm_key_vault_key_id" {
  description = "The ID of the key vault key"
  value       = azurerm_key_vault_key.this.id
}
