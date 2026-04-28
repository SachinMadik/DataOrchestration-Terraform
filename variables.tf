variable "subscription_id" {
  default = "aecb99f2-8133-42cc-9e22-2e66acddf913"
}

variable "location" {
  default = "eastus"
}

variable "location_eastus2" {
  default = "eastus2"
}

variable "apim_publisher_name" {
  default = "DataOrchestration"
}

variable "apim_publisher_email" {
  default = "navya.p@cloudthat.com"
}

variable "jwt_secret" {
  description = "JWT signing secret for the Function App"
  sensitive   = true
}
