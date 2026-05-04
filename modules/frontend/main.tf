resource "azurerm_static_web_app" "frontend" {
  name                = var.static_web_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"

  app_settings = {
    VITE_AZURE_API_URL         = var.apim_gateway_url
    VITE_APIM_SUBSCRIPTION_KEY = var.apim_subscription_key
  }
}
