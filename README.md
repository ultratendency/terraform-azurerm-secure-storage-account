# Azure Secure Storage Account Terraform module

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=ultratendency_terraform-azurerm-secure-storage-account&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=ultratendency_terraform-azurerm-secure-storage-account)

Terraform module which creates a Storage Account on Azure with secure defaults.

## Usage

The simplest usage of this module is shown below. It requires a few parameters to passed in and
already uses the recommended default configuraton values. Please note that the resource group
used for the deployment will not be created by this module.

```terraform
data "azurerm_resource_group" "tstate" {
  name = "tstate"
}

module "terraform_state_storage_account" {
  source  = "ultratendency/secure-storage-account/azurerm"
  version = "4.0.0"

  storage_account_name                = "tstate"
  storage_account_resource_group_name = data.azurerm_resource_group.tstate.name
  storage_account_location            = "westeurope"
  storage_container_name              = "tstate"
  key_vault_name                      = "tstate-vault"
  key_vault_key_name                  = "tstate-vault-key"
  key_vault_key_expiration_date       = "2023-12-30T20:00:00Z"
}
```

A complete example looks like the following, where all inputs are configured. Please note that the
following is only a descriptive example and does not follow recommended configuration values.

```terraform
data "azurerm_resource_group" "tstate" {
  name = "tstate"
}

module "terraform_state_storage_account" {
  source  = "ultratendency/secure-storage-account/azurerm"
  version = "4.0.0"

  storage_account_name                                                   = "tstate"
  storage_account_resource_group_name                                    = data.azurerm_resource_group.tstate.name
  storage_account_location                                               = "westeurope"
  storage_account_account_tier                                           = "Premium"
  storage_account_account_replication_type                               = "GRS"
  storage_account_min_tls_version                                        = "TLS1_1"
  storage_account_https_traffic_only_enabled                             = false
  storage_account_queue_encryption_key_type                              = "Account"
  storage_account_table_encryption_key_type                              = "Account"
  storage_account_infrastructure_encryption_enabled                      = true
  storage_account_allow_nested_items_to_be_public                        = true
  storage_account_shared_access_key_enabled                              = true
  storage_account_queue_properties_logging_delete                        = false
  storage_account_queue_properties_logging_read                          = false
  storage_account_queue_properties_logging_write                         = false
  storage_account_queue_properties_logging_version                       = "1.0"
  storage_account_queue_properties_logging_retention_policy_days         = 20
  storage_account_queue_properties_hour_metrics_include_apis             = false
  storage_account_queue_properties_hour_metrics_version                  = "1.0"
  storage_account_queue_properties_hour_metrics_retention_policy_days    = 20
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
```

### Microsoft Entra user account as the authentication method

When leaving the variable `storage_account_shared_access_key_enabled` with the default value
`false` shared access keys are turned off on the storage account. This needs some configuration on
the storage account itself, as outlined below

#### Permissions

The user principal running Terraform needs to have the `Storage Blob Data Contributor` role
assigned. Please note that having the `Owner` or `Contributor` role assigned is not sufficient as
the user prinicipal needs one of the `Storage Blob Data xxx` roles to access data within the
storage blob.

Permissions can also directly assigned via the `storage_account_role_assignments` variable (or the respective
`key_vault_role_assignments` variable for the Key Vault), similar to the following example

```terraform
...
storage_account_role_assignments = {
  user_1 = {
    principal_id         = "123"
    role_definition_name = "Storage Blob Data Contributor"
  }
  user_2 = {
    principal_id         = "456"
    role_definition_name = "Storage Blob Data Contributor"
  }
}
...
```

#### Storage Container configuration

With the use of `storage_account_shared_access_key_enabled` the authentication method for the
storage container will be switched to `Microsoft Entra user account`. Ensure that this change
happened.

#### Terraform backend configuration

The recommended usage for the storage account as a Terraform backend is to use the authentication
method `Service Principal or User Assigned Managed Identity via OIDC (Workload identity federation)`
with `Azure AD` as the storage account authentication type. To configure both, the Terraform
backend should contain the following configuration values

```terraform
...
use_azuread_auth = true,
use_oidc         = true,
...
```

A complete Terraform backend configuration would look like the following

```terraform
terraform {
  backend "azurerm" {
    resource_group_name  = "tstate"
    storage_account_name = "tstate"
    container_name       = "tstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}
```

For a detailed look into available options, see the
[available configuration options](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm).

#### Terraform provider configuration

To let the Terraform provider access the storage account without a shared access key, the following
configuration needs to be set on the provider

```terraform
...
storage_use_azuread = true
...
```

A complete Terraform provider configuration would look like the following

```terraform
provider "azurerm" {
  use_oidc            = true
  storage_use_azuread = true
  features {}
}
```
