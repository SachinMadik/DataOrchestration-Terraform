resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_api" "funcapi" {
  name                  = "dataorch-api"
  resource_group_name   = var.resource_group_name
  api_management_name   = azurerm_api_management.apim.name
  revision              = "1"
  display_name          = "DataOrch API"
  path                  = "api"
  protocols             = ["https"]
  service_url           = "https://${var.function_app_hostname}/api"
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "get" {
  operation_id        = "wildcard-get"
  api_name            = azurerm_api_management_api.funcapi.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  display_name        = "Wildcard GET"
  method              = "GET"
  url_template        = "/*"
}

resource "azurerm_api_management_api_operation" "post" {
  operation_id        = "wildcard-post"
  api_name            = azurerm_api_management_api.funcapi.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  display_name        = "Wildcard POST"
  method              = "POST"
  url_template        = "/*"
}

resource "azurerm_api_management_api_operation" "delete" {
  operation_id        = "wildcard-delete"
  api_name            = azurerm_api_management_api.funcapi.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  display_name        = "Wildcard DELETE"
  method              = "DELETE"
  url_template        = "/*"
}

resource "azurerm_api_management_api_policy" "cors" {
  api_name            = azurerm_api_management_api.funcapi.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name

  xml_content = <<XML
<policies>
  <inbound>
    <cors allow-credentials="false">
      <allowed-origins>
        <origin>*</origin>
      </allowed-origins>
      <allowed-methods preflight-result-max-age="300">
        <method>GET</method>
        <method>POST</method>
        <method>PUT</method>
        <method>DELETE</method>
        <method>OPTIONS</method>
      </allowed-methods>
      <allowed-headers>
        <header>*</header>
      </allowed-headers>
    </cors>
    <base />
  </inbound>
  <backend><base /></backend>
  <outbound><base /></outbound>
  <on-error><base /></on-error>
</policies>
XML
}
