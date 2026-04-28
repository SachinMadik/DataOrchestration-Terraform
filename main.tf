# ── 1. Resource Group ─────────────────────────────────────────────────────────
module "resource_group" {
  source   = "./modules/resource-group"
  name     = local.names.resource_group
  location = local.location
}

# ── 2. Monitoring ─────────────────────────────────────────────────────────────
module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  law_name            = local.names.law
  app_insights_name   = local.names.app_insights
}

# ── 3. Storage ────────────────────────────────────────────────────────────────
module "storage" {
  source               = "./modules/storage"
  resource_group_name  = module.resource_group.name
  location             = module.resource_group.location
  storage_account_name = local.names.storage
}

# ── 4. Networking ─────────────────────────────────────────────────────────────
module "networking" {
  source              = "./modules/networking"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = local.names.vnet
  nsg_name            = local.names.nsg
}

# ── 5. AI Services ────────────────────────────────────────────────────────────
module "ai_services" {
  source                = "./modules/ai-services"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  openai_name           = local.names.openai
  doc_intelligence_name = local.names.doc_intelligence
}

# ── 6. Key Vault (receives secrets from storage + ai) ─────────────────────────
module "keyvault" {
  source                    = "./modules/keyvault"
  resource_group_name       = module.resource_group.name
  location                  = module.resource_group.location
  key_vault_name            = local.names.key_vault
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  deployer_object_id        = data.azurerm_client_config.current.object_id
  storage_connection_string = module.storage.primary_connection_string
  openai_api_key            = module.ai_services.openai_api_key
  doc_intelligence_key      = module.ai_services.doc_intelligence_key
}

# ── 7. Compute (depends on storage + ai + monitoring) ─────────────────────────
module "compute" {
  source                         = "./modules/compute"
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  asp_name                       = local.names.asp
  function_app_name              = local.names.function_app
  storage_container_endpoint     = module.storage.deployments_container_endpoint
  storage_account_access_key     = module.storage.primary_access_key
  storage_connection_string      = module.storage.primary_connection_string
  app_insights_connection_string = module.monitoring.app_insights_connection_string
  openai_endpoint                = module.ai_services.openai_endpoint
  openai_api_key                 = module.ai_services.openai_api_key
  doc_intelligence_endpoint      = module.ai_services.doc_intelligence_endpoint
  doc_intelligence_key           = module.ai_services.doc_intelligence_key
  jwt_secret                     = var.jwt_secret
}

# ── 8. API Management (depends on compute) ────────────────────────────────────
module "api_management" {
  source                = "./modules/api-management"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  apim_name             = local.names.apim
  publisher_name        = var.apim_publisher_name
  publisher_email       = var.apim_publisher_email
  function_app_hostname = module.compute.function_app_hostname
}

# ── 9. Frontend (depends on apim) ─────────────────────────────────────────────
module "frontend" {
  source              = "./modules/frontend"
  resource_group_name = module.resource_group.name
  location            = var.location_eastus2
  static_web_app_name = local.names.static_web_app
}
