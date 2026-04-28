output "resource_group_name" {
  value = module.resource_group.name
}

output "function_app_url" {
  value = "https://${module.compute.function_app_hostname}"
}

output "apim_gateway_url" {
  value = module.api_management.gateway_url
}

output "frontend_hostname" {
  value = module.frontend.hostname
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "key_vault_uri" {
  value = module.keyvault.vault_uri
}

output "openai_endpoint" {
  value = module.ai_services.openai_endpoint
}

output "doc_intelligence_endpoint" {
  value = module.ai_services.doc_intelligence_endpoint
}

output "app_insights_connection_string" {
  value     = module.monitoring.app_insights_connection_string
  sensitive = true
}
