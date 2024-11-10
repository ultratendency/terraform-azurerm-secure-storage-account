# General variables
variable "tags" {
  type    = map(string)
  default = {}
}

# azurerm_storage_account variables
variable "storage_account_name" {
  type        = string
  description = "The name of the storage sccount"
}

variable "storage_account_resource_group_name" {
  type        = string
  description = "The name of the resource group to use"
}

variable "storage_account_location" {
  type        = string
  description = "The location of the storage account"
}

variable "storage_account_account_tier" {
  type        = string
  description = "(optional) The tier to use for this storage account"
  default     = "Standard"
}

variable "storage_account_account_replication_type" {
  type        = string
  description = "(optional) The type of replication to use for this storage account"
  default     = "LRS"
}

variable "storage_account_min_tls_version" {
  type        = string
  description = "(optional) The minimum supported TLS version for this storage account"
  default     = "TLS1_2"
}

variable "storage_account_https_traffic_only_enabled" {
  type        = bool
  description = "(optional) Boolean flag which forces HTTPS if enabled"
  default     = true
}

variable "storage_account_queue_encryption_key_type" {
  type        = string
  description = "(optional) The encryption of the queue service"
  default     = "Service"
}

variable "storage_account_table_encryption_key_type" {
  type        = string
  description = "(optional) The encryption type of the table service"
  default     = "Service"
}

variable "storage_account_infrastructure_encryption_enabled" {
  type        = bool
  description = "(optional) Boolean flag which forces infrastructure encryption"
  default     = false
}

variable "storage_account_allow_nested_items_to_be_public" {
  type        = bool
  description = "(optional) Allow or disallow nested items within this storage account to opt into being public"
  default     = false
}

variable "storage_account_shared_access_key_enabled" {
  type        = bool
  description = "(optional) Indicates whether the storage account permits requests to be authorized with the account access key"
  default     = false
}

variable "storage_account_queue_properties_logging_delete" {
  type        = bool
  description = "(optional) Indicates whether all delete requests should be logged"
  default     = true
}

variable "storage_account_queue_properties_logging_read" {
  type        = bool
  description = "(optional) Indicates whether all read requests should be logged"
  default     = true
}

variable "storage_account_queue_properties_logging_write" {
  type        = bool
  description = "(optional) Indicates whether all write requests should be logged"
  default     = true
}

variable "storage_account_queue_properties_logging_version" {
  type        = string
  description = "(optional) The version of storage analytics to configure"
  default     = "1.0"
}

variable "storage_account_queue_properties_logging_retention_policy_days" {
  type        = number
  description = "(optional) The number of days that logs will be retained"
  default     = 10
}

variable "storage_account_queue_properties_hour_metrics_include_apis" {
  type        = bool
  description = "(optional) Indicates whether metrics should generate summary statistics for called API operations"
  default     = true
}

variable "storage_account_queue_properties_hour_metrics_version" {
  type        = string
  description = "(optional) The version of the storage analytics to configure"
  default     = "1.0"
}

variable "storage_account_queue_properties_hour_metrics_retention_policy_days" {
  type        = number
  description = "(optional) The number of days that logs will be retained"
  default     = 10
}

variable "storage_account_queue_properties_minute_metrics_include_apis" {
  type        = bool
  description = "(optional) Indicates whether metrics should generate summary statistics for called API operations"
  default     = true
}

variable "storage_account_queue_properties_minute_metrics_version" {
  type        = string
  description = "(optional) The version of storage analytics to configure"
  default     = "1.0"
}

variable "storage_account_queue_properties_minute_metrics_retention_policy_days" {
  type        = number
  description = "(optional) The number of days that logs will be retained"
  default     = 10
}

variable "storage_account_blob_properties_change_feed_enabled" {
  type        = bool
  description = "(optional) Indicates whether the blob service properties for change feeds are enabled"
  default     = true
}

variable "storage_account_blob_properties_change_feed_retention_in_days" {
  type        = number
  description = "(optional) The number of days that change feed eents will be retained"
  default     = 7
}

variable "storage_account_blob_properties_versioning_enabled" {
  type        = bool
  description = "(optional) Indicates whether versioning is enabled"
  default     = true
}

variable "storage_account_blob_properties_container_delete_retention_policy_days" {
  type        = number
  description = "(optional) The number of days that the container should be retained"
  default     = 7
}

variable "storage_account_blob_properties_delete_retention_policy_days" {
  type        = number
  description = "(optional) The number of days that the blob should be retained"
  default     = 7
}

# azurerm_storage_container variables
variable "storage_container_name" {
  type        = string
  description = "The name of the container which should be created within the storage account"
}

variable "storage_container_container_access_type" {
  type        = string
  description = "(optional) The access level configured for the container"
  default     = "private"
}

# azurerm_key_vault variables
variable "key_vault_name" {
  type        = string
  description = "The name of the key vault"
}

variable "key_vault_sku_name" {
  type        = string
  description = "(optiona) The name of the SKU used for the key vault"
  default     = "standard"
}

variable "key_vault_enable_rbac_authorization" {
  type        = bool
  description = "(optional) Indicates whether the key vault uses Role Based Access Control (RBAC) for authorization of data actions"
  default     = true
}

variable "key_vault_purge_protection_enabled" {
  type        = bool
  description = "(optional) Indicates whether purge protection is enabled for the key vault"
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  type        = number
  description = "(optional) The number of days that items should be retained for once soft-deleted"
  default     = 90
}

# azurerm_key_vault_key variables
variable "key_vault_key_name" {
  type        = string
  description = "The name of the key vault key"
}

variable "key_vault_key_key_type" {
  type        = string
  description = "(optional) The key type to use for this key vault key"
  default     = "RSA"
}

variable "key_vault_key_key_size" {
  type        = number
  description = "(optional) The size of the RSA key to create in bytes"
  default     = 4096
}

variable "key_vault_key_key_opts" {
  type        = list(string)
  description = "(optional) A list of JSON web key operations"
  default     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

variable "key_vault_key_expiration_date" {
  type        = string
  description = "Expiration UTC datetime of the key vault key"
}
