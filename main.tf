data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "this" {
  name                              = var.storage_account_name
  resource_group_name               = var.storage_account_resource_group_name
  location                          = var.storage_account_location
  account_tier                      = var.storage_account_account_tier
  account_replication_type          = var.storage_account_account_replication_type
  min_tls_version                   = var.storage_account_min_tls_version
  https_traffic_only_enabled        = var.storage_account_https_traffic_only_enabled
  queue_encryption_key_type         = var.storage_account_queue_encryption_key_type
  table_encryption_key_type         = var.storage_account_table_encryption_key_type
  infrastructure_encryption_enabled = var.storage_account_infrastructure_encryption_enabled
  allow_nested_items_to_be_public   = var.storage_account_allow_nested_items_to_be_public
  shared_access_key_enabled         = var.storage_account_shared_access_key_enabled

  blob_properties {
    change_feed_enabled           = var.storage_account_blob_properties_change_feed_enabled
    change_feed_retention_in_days = var.storage_account_blob_properties_change_feed_retention_in_days
    versioning_enabled            = var.storage_account_blob_properties_versioning_enabled

    container_delete_retention_policy {
      days = var.storage_account_blob_properties_container_delete_retention_policy_days
    }

    delete_retention_policy {
      days = var.storage_account_blob_properties_delete_retention_policy_days
    }
  }

  tags = var.tags
}

resource "azurerm_storage_account_queue_properties" "this" {
  storage_account_id = azurerm_storage_account.this.id

  logging {
    delete                = var.storage_account_queue_properties_logging_delete
    read                  = var.storage_account_queue_properties_logging_read
    write                 = var.storage_account_queue_properties_logging_write
    version               = var.storage_account_queue_properties_logging_version
    retention_policy_days = var.storage_account_queue_properties_logging_retention_policy_days
  }

  hour_metrics {
    include_apis          = var.storage_account_queue_properties_hour_metrics_include_apis
    version               = var.storage_account_queue_properties_hour_metrics_version
    retention_policy_days = var.storage_account_queue_properties_hour_metrics_retention_policy_days
  }

  minute_metrics {
    include_apis          = var.storage_account_queue_properties_minute_metrics_include_apis
    version               = var.storage_account_queue_properties_minute_metrics_version
    retention_policy_days = var.storage_account_queue_properties_minute_metrics_retention_policy_days
  }
}

resource "azurerm_storage_container" "this" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = var.storage_container_container_access_type
}

resource "azurerm_role_assignment" "this_storage_account" {
  for_each = var.storage_account_role_assignments

  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = azurerm_storage_account.this.id
}

resource "azurerm_key_vault" "this" {
  name                      = var.key_vault_name
  resource_group_name       = var.storage_account_resource_group_name
  location                  = var.storage_account_location
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = var.key_vault_sku_name
  enable_rbac_authorization = var.key_vault_enable_rbac_authorization

  purge_protection_enabled   = var.key_vault_purge_protection_enabled
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days

  tags = var.tags
}

resource "azurerm_key_vault_key" "this" {
  name            = var.key_vault_key_name
  key_vault_id    = azurerm_key_vault.this.id
  key_type        = var.key_vault_key_key_type
  key_size        = var.key_vault_key_key_size
  key_opts        = var.key_vault_key_key_opts
  expiration_date = var.key_vault_key_expiration_date

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.this_key_vault,
  ]
}

resource "azurerm_role_assignment" "this_key_vault" {
  for_each = var.key_vault_role_assignments

  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = azurerm_key_vault.this.id
}
