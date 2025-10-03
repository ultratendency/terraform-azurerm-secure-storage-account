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

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.47.0 |



## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_role_assignment.this_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_queue_properties.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_queue_properties) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_vault_enable_rbac_authorization"></a> [key\_vault\_enable\_rbac\_authorization](#input\_key\_vault\_enable\_rbac\_authorization) | (optional) Indicates whether the key vault uses Role Based Access Control (RBAC) for authorization of data actions | `bool` | `true` | no |
| <a name="input_key_vault_key_expiration_date"></a> [key\_vault\_key\_expiration\_date](#input\_key\_vault\_key\_expiration\_date) | Expiration UTC datetime of the key vault key | `string` | n/a | yes |
| <a name="input_key_vault_key_key_opts"></a> [key\_vault\_key\_key\_opts](#input\_key\_vault\_key\_key\_opts) | (optional) A list of JSON web key operations | `list(string)` | <pre>[<br/>  "decrypt",<br/>  "encrypt",<br/>  "sign",<br/>  "unwrapKey",<br/>  "verify",<br/>  "wrapKey"<br/>]</pre> | no |
| <a name="input_key_vault_key_key_size"></a> [key\_vault\_key\_key\_size](#input\_key\_vault\_key\_key\_size) | (optional) The size of the RSA key to create in bytes | `number` | `4096` | no |
| <a name="input_key_vault_key_key_type"></a> [key\_vault\_key\_key\_type](#input\_key\_vault\_key\_key\_type) | (optional) The key type to use for this key vault key | `string` | `"RSA"` | no |
| <a name="input_key_vault_key_name"></a> [key\_vault\_key\_name](#input\_key\_vault\_key\_name) | The name of the key vault key | `string` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | The name of the key vault | `string` | n/a | yes |
| <a name="input_key_vault_purge_protection_enabled"></a> [key\_vault\_purge\_protection\_enabled](#input\_key\_vault\_purge\_protection\_enabled) | (optional) Indicates whether purge protection is enabled for the key vault | `bool` | `true` | no |
| <a name="input_key_vault_role_assignments"></a> [key\_vault\_role\_assignments](#input\_key\_vault\_role\_assignments) | (optional) A map of role assignments to be created for the key vault | <pre>map(object({<br/>    principal_id         = string<br/>    role_definition_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_key_vault_sku_name"></a> [key\_vault\_sku\_name](#input\_key\_vault\_sku\_name) | (optiona) The name of the SKU used for the key vault | `string` | `"standard"` | no |
| <a name="input_key_vault_soft_delete_retention_days"></a> [key\_vault\_soft\_delete\_retention\_days](#input\_key\_vault\_soft\_delete\_retention\_days) | (optional) The number of days that items should be retained for once soft-deleted | `number` | `90` | no |
| <a name="input_storage_account_account_replication_type"></a> [storage\_account\_account\_replication\_type](#input\_storage\_account\_account\_replication\_type) | (optional) The type of replication to use for this storage account | `string` | `"LRS"` | no |
| <a name="input_storage_account_account_tier"></a> [storage\_account\_account\_tier](#input\_storage\_account\_account\_tier) | (optional) The tier to use for this storage account | `string` | `"Standard"` | no |
| <a name="input_storage_account_allow_nested_items_to_be_public"></a> [storage\_account\_allow\_nested\_items\_to\_be\_public](#input\_storage\_account\_allow\_nested\_items\_to\_be\_public) | (optional) Allow or disallow nested items within this storage account to opt into being public | `bool` | `false` | no |
| <a name="input_storage_account_blob_properties_change_feed_enabled"></a> [storage\_account\_blob\_properties\_change\_feed\_enabled](#input\_storage\_account\_blob\_properties\_change\_feed\_enabled) | (optional) Indicates whether the blob service properties for change feeds are enabled | `bool` | `true` | no |
| <a name="input_storage_account_blob_properties_change_feed_retention_in_days"></a> [storage\_account\_blob\_properties\_change\_feed\_retention\_in\_days](#input\_storage\_account\_blob\_properties\_change\_feed\_retention\_in\_days) | (optional) The number of days that change feed eents will be retained | `number` | `7` | no |
| <a name="input_storage_account_blob_properties_container_delete_retention_policy_days"></a> [storage\_account\_blob\_properties\_container\_delete\_retention\_policy\_days](#input\_storage\_account\_blob\_properties\_container\_delete\_retention\_policy\_days) | (optional) The number of days that the container should be retained | `number` | `7` | no |
| <a name="input_storage_account_blob_properties_delete_retention_policy_days"></a> [storage\_account\_blob\_properties\_delete\_retention\_policy\_days](#input\_storage\_account\_blob\_properties\_delete\_retention\_policy\_days) | (optional) The number of days that the blob should be retained | `number` | `7` | no |
| <a name="input_storage_account_blob_properties_versioning_enabled"></a> [storage\_account\_blob\_properties\_versioning\_enabled](#input\_storage\_account\_blob\_properties\_versioning\_enabled) | (optional) Indicates whether versioning is enabled | `bool` | `true` | no |
| <a name="input_storage_account_https_traffic_only_enabled"></a> [storage\_account\_https\_traffic\_only\_enabled](#input\_storage\_account\_https\_traffic\_only\_enabled) | (optional) Boolean flag which forces HTTPS if enabled | `bool` | `true` | no |
| <a name="input_storage_account_infrastructure_encryption_enabled"></a> [storage\_account\_infrastructure\_encryption\_enabled](#input\_storage\_account\_infrastructure\_encryption\_enabled) | (optional) Boolean flag which forces infrastructure encryption | `bool` | `false` | no |
| <a name="input_storage_account_location"></a> [storage\_account\_location](#input\_storage\_account\_location) | The location of the storage account | `string` | n/a | yes |
| <a name="input_storage_account_min_tls_version"></a> [storage\_account\_min\_tls\_version](#input\_storage\_account\_min\_tls\_version) | (optional) The minimum supported TLS version for this storage account | `string` | `"TLS1_2"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage sccount | `string` | n/a | yes |
| <a name="input_storage_account_queue_encryption_key_type"></a> [storage\_account\_queue\_encryption\_key\_type](#input\_storage\_account\_queue\_encryption\_key\_type) | (optional) The encryption of the queue service | `string` | `"Service"` | no |
| <a name="input_storage_account_queue_properties_hour_metrics_include_apis"></a> [storage\_account\_queue\_properties\_hour\_metrics\_include\_apis](#input\_storage\_account\_queue\_properties\_hour\_metrics\_include\_apis) | (optional) Indicates whether metrics should generate summary statistics for called API operations | `bool` | `true` | no |
| <a name="input_storage_account_queue_properties_hour_metrics_retention_policy_days"></a> [storage\_account\_queue\_properties\_hour\_metrics\_retention\_policy\_days](#input\_storage\_account\_queue\_properties\_hour\_metrics\_retention\_policy\_days) | (optional) The number of days that logs will be retained | `number` | `10` | no |
| <a name="input_storage_account_queue_properties_hour_metrics_version"></a> [storage\_account\_queue\_properties\_hour\_metrics\_version](#input\_storage\_account\_queue\_properties\_hour\_metrics\_version) | (optional) The version of the storage analytics to configure | `string` | `"1.0"` | no |
| <a name="input_storage_account_queue_properties_logging_delete"></a> [storage\_account\_queue\_properties\_logging\_delete](#input\_storage\_account\_queue\_properties\_logging\_delete) | (optional) Indicates whether all delete requests should be logged | `bool` | `true` | no |
| <a name="input_storage_account_queue_properties_logging_read"></a> [storage\_account\_queue\_properties\_logging\_read](#input\_storage\_account\_queue\_properties\_logging\_read) | (optional) Indicates whether all read requests should be logged | `bool` | `true` | no |
| <a name="input_storage_account_queue_properties_logging_retention_policy_days"></a> [storage\_account\_queue\_properties\_logging\_retention\_policy\_days](#input\_storage\_account\_queue\_properties\_logging\_retention\_policy\_days) | (optional) The number of days that logs will be retained | `number` | `10` | no |
| <a name="input_storage_account_queue_properties_logging_version"></a> [storage\_account\_queue\_properties\_logging\_version](#input\_storage\_account\_queue\_properties\_logging\_version) | (optional) The version of storage analytics to configure | `string` | `"1.0"` | no |
| <a name="input_storage_account_queue_properties_logging_write"></a> [storage\_account\_queue\_properties\_logging\_write](#input\_storage\_account\_queue\_properties\_logging\_write) | (optional) Indicates whether all write requests should be logged | `bool` | `true` | no |
| <a name="input_storage_account_queue_properties_minute_metrics_include_apis"></a> [storage\_account\_queue\_properties\_minute\_metrics\_include\_apis](#input\_storage\_account\_queue\_properties\_minute\_metrics\_include\_apis) | (optional) Indicates whether metrics should generate summary statistics for called API operations | `bool` | `true` | no |
| <a name="input_storage_account_queue_properties_minute_metrics_retention_policy_days"></a> [storage\_account\_queue\_properties\_minute\_metrics\_retention\_policy\_days](#input\_storage\_account\_queue\_properties\_minute\_metrics\_retention\_policy\_days) | (optional) The number of days that logs will be retained | `number` | `10` | no |
| <a name="input_storage_account_queue_properties_minute_metrics_version"></a> [storage\_account\_queue\_properties\_minute\_metrics\_version](#input\_storage\_account\_queue\_properties\_minute\_metrics\_version) | (optional) The version of storage analytics to configure | `string` | `"1.0"` | no |
| <a name="input_storage_account_resource_group_name"></a> [storage\_account\_resource\_group\_name](#input\_storage\_account\_resource\_group\_name) | The name of the resource group to use | `string` | n/a | yes |
| <a name="input_storage_account_role_assignments"></a> [storage\_account\_role\_assignments](#input\_storage\_account\_role\_assignments) | (optional) A map of role assignments to be created for the storage account | <pre>map(object({<br/>    principal_id         = string<br/>    role_definition_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_storage_account_shared_access_key_enabled"></a> [storage\_account\_shared\_access\_key\_enabled](#input\_storage\_account\_shared\_access\_key\_enabled) | (optional) Indicates whether the storage account permits requests to be authorized with the account access key | `bool` | `false` | no |
| <a name="input_storage_account_table_encryption_key_type"></a> [storage\_account\_table\_encryption\_key\_type](#input\_storage\_account\_table\_encryption\_key\_type) | (optional) The encryption type of the table service | `string` | `"Service"` | no |
| <a name="input_storage_container_container_access_type"></a> [storage\_container\_container\_access\_type](#input\_storage\_container\_container\_access\_type) | (optional) The access level configured for the container | `string` | `"private"` | no |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | The name of the container which should be created within the storage account | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | General variables | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_key_vault_id"></a> [azurerm\_key\_vault\_id](#output\_azurerm\_key\_vault\_id) | The ID of the key vault |
| <a name="output_azurerm_key_vault_key_id"></a> [azurerm\_key\_vault\_key\_id](#output\_azurerm\_key\_vault\_key\_id) | The ID of the key vault key |
| <a name="output_azurerm_storage_account_id"></a> [azurerm\_storage\_account\_id](#output\_azurerm\_storage\_account\_id) | The ID of the storage account |
| <a name="output_azurerm_storage_container_id"></a> [azurerm\_storage\_container\_id](#output\_azurerm\_storage\_container\_id) | The ID of the storage container |

## Examples

An simple example of the default configuration can be found below:

```hcl
provider "azurerm" {
  features {}
}

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

A more complex example can be found below:

```hcl
provider "azurerm" {
  features {}
}

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

<!-- END_TF_DOCS -->
