resource "azurerm_service_plan" "asp" {
  name                = var.asp_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "FC1"
}

resource "azurerm_linux_function_app" "funcapp" {
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  service_plan_id            = azurerm_service_plan.asp.id

  site_config {
    application_insights_connection_string = var.app_insights_connection_string
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    AZURE_STORAGE_CONNECTION_STRING       = var.storage_connection_string
    AZURE_OPENAI_ENDPOINT                 = var.openai_endpoint
    AZURE_OPENAI_API_KEY                  = var.openai_api_key
    DOC_INTELLIGENCE_ENDPOINT             = var.doc_intelligence_endpoint
    DOC_INTELLIGENCE_KEY                  = var.doc_intelligence_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_insights_connection_string
    JWT_SECRET                            = var.jwt_secret
    AZURE_SEARCH_ENDPOINT                 = "https://not-used.search.windows.net"
    AZURE_SEARCH_KEY                      = "not-used"
    WEBSITE_RUN_FROM_PACKAGE              = "1"
  }

  lifecycle {
    ignore_changes = [app_settings["WEBSITE_RUN_FROM_PACKAGE"]]
  }
}
