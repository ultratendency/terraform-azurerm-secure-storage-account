provider "azurerm" {
  features {}
}

module "terraform_state_storage_account" {
  source  = "ultratendency/secure-storage-account/azurerm"
  version = "1.0.0"

  storage_account_name                                                   = "tstate"
  storage_account_resource_group_name                                    = "tstate"
  storage_account_location                                               = "westeurope"
  storage_account_account_tier                                           = "Premium"
  storage_account_account_replication_type                               = "GRS"
  storage_account_min_tls_version                                        = "TLS1_1"
  storage_account_enable_https_traffic_only                              = false
  storage_account_queue_encryption_key_type                              = "Account"
  storage_account_table_encryption_key_type                              = "Account"
  storage_account_infrastructure_encryption_enabled                      = true
  storage_account_allow_nested_items_to_be_public                        = true
  storage_account_queue_properties_logging_delete                        = false
  storage_account_queue_properties_logging_read                          = false
  storage_account_queue_properties_logging_write                         = false
  storage_account_queue_properties_logging_version                       = "1.0"
  storage_account_queue_properties_logging_retention_policy_days         = 20
  storage_account_queue_properties_hour_metrics_enabled                  = false
  storage_account_queue_properties_hour_metrics_include_apis             = false
  storage_account_queue_properties_hour_metrics_version                  = "1.0"
  storage_account_queue_properties_hour_metrics_retention_policy_days    = 20
  storage_account_queue_properties_minute_metrics_enabled                = false
  storage_account_queue_properties_minute_metrics_include_apis           = false
  storage_account_queue_properties_minute_metrics_version                = "1.0"
  storage_account_queue_properties_minute_metrics_retention_policy_days  = 20
  storage_account_blob_properties_change_feed_enabled                    = false
  storage_account_blob_properties_change_feed_retention_in_days          = 14
  storage_account_blob_properties_versioning_enabled                     = false
  storage_account_blob_properties_container_delete_retention_policy_days = 14
  storage_account_blob_properties_delete_retention_policy_days           = 14

  storage_container_name                  = "tstate"
  storage_container_container_access_type = "blob"

  key_vault_name                       = "tstate-vault"
  key_vault_sku_name                   = "premium"
  key_vault_enable_rbac_authorization  = false
  key_vault_purge_protection_enabled   = false
  key_vault_soft_delete_retention_days = 7

  key_vault_key_name            = "tstate-vault-key"
  key_vault_key_key_type        = "EC"
  key_vault_key_key_size        = "1024"
  key_vault_key_key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify"]
  key_vault_key_expiration_date = "2023-12-30T20:00:00Z"
}
