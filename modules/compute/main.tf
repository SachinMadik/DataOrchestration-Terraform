resource "azurerm_service_plan" "asp" {
  name                = var.asp_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "FC1"
}

resource "azurerm_function_app_flex_consumption" "funcapp" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp.id

  runtime_name    = "python"
  runtime_version = "3.10"

  instance_memory_in_mb = 2048

  storage_container_type     = "blobContainer"
  storage_container_endpoint = var.storage_container_endpoint
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key         = var.storage_account_access_key

  app_settings = {
    AZURE_STORAGE_CONNECTION_STRING       = var.storage_connection_string
    AZURE_OPENAI_ENDPOINT                 = var.openai_endpoint
    AZURE_OPENAI_API_KEY                  = var.openai_api_key
    DOC_INTELLIGENCE_ENDPOINT             = var.doc_intelligence_endpoint
    DOC_INTELLIGENCE_KEY                  = var.doc_intelligence_key
    JWT_SECRET                      = var.jwt_secret
    AZURE_SEARCH_ENDPOINT                 = "https://not-used.search.windows.net"
    AZURE_SEARCH_KEY                      = "not-used"
  }

  site_config {
    application_insights_connection_string = var.app_insights_connection_string
  }
}
