output "openai_endpoint"              { value = azurerm_cognitive_account.openai.endpoint }
output "openai_api_key"               { value = azurerm_cognitive_account.openai.primary_access_key; sensitive = true }
output "doc_intelligence_endpoint"    { value = azurerm_cognitive_account.docintel.endpoint }
output "doc_intelligence_key"         { value = azurerm_cognitive_account.docintel.primary_access_key; sensitive = true }
