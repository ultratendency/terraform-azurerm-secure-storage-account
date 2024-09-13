provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "tstate" {
  name = "tstate"
}

module "terraform_state_storage_account" {
  source  = "ultratendency/secure-storage-account/azurerm"
  version = "3.0.3"

  storage_account_name                = "tstate"
  storage_account_resource_group_name = data.azurerm_resource_group.tstate.name
  storage_account_location            = "westeurope"
  storage_container_name              = "tstate"
  key_vault_name                      = "tstate-vault"
  key_vault_key_name                  = "tstate-vault-key"
  key_vault_key_expiration_date       = "2023-12-30T20:00:00Z"
}
