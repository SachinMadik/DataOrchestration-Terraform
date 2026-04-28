resource "azurerm_cognitive_account" "openai" {
  name                = var.openai_name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "OpenAI"
  sku_name            = "S0"
}

resource "azurerm_cognitive_deployment" "embedding" {
  name                 = "text-embedding-3-small"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "text-embedding-3-small"
    version = "1"
  }
  sku {
    name     = "Standard"
    capacity = 50
  }
}

resource "azurerm_cognitive_deployment" "gpt" {
  name                 = "gpt-4.1-mini"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4.1-mini"
    version = "2025-04-14"
  }
  sku {
    name     = "Standard"
    capacity = 50
  }

  depends_on = [azurerm_cognitive_deployment.embedding]
}

resource "azurerm_cognitive_account" "docintel" {
  name                = var.doc_intelligence_name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "FormRecognizer"
  sku_name            = "F0"
}
