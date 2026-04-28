resource "azurerm_key_vault" "kv" {
  name                       = var.key_vault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_secret" "storage_connection" {
  name         = "storage-connection-string"
  value        = var.storage_connection_string
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "openai_key" {
  name         = "openai-api-key"
  value        = var.openai_api_key
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "docintel_key" {
  name         = "docintel-api-key"
  value        = var.doc_intelligence_key
  key_vault_id = azurerm_key_vault.kv.id
}
