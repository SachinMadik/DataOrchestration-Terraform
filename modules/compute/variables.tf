variable "resource_group_name" {}
variable "location" {}
variable "asp_name" {}
variable "function_app_name" {}
variable "storage_account_access_key" { sensitive = true }
variable "storage_connection_string" { sensitive = true }
variable "storage_container_endpoint" {}
variable "app_insights_connection_string" { sensitive = true }
variable "openai_endpoint" {}
variable "openai_api_key" { sensitive = true }
variable "doc_intelligence_endpoint" {}
variable "doc_intelligence_key" { sensitive = true }
variable "jwt_secret" { sensitive = true }
variable "search_endpoint" {}
variable "search_key" { sensitive = true }