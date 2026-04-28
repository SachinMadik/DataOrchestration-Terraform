variable "resource_group_name" {}
variable "location" {}
variable "key_vault_name" {}
variable "tenant_id" {}
variable "deployer_object_id" {}
variable "storage_connection_string" { sensitive = true }
variable "openai_api_key" { sensitive = true }
variable "doc_intelligence_key" { sensitive = true }
