locals {
  prefix   = "dataorch-new"
  location = var.location

  names = {
    resource_group    = "Data-Orchestration-Terraform"
    storage           = "dataorchnewstorage"
    law               = "${local.prefix}-law"
    app_insights      = "${local.prefix}-appinsights"
    asp               = "${local.prefix}-asp"
    function_app      = "${local.prefix}-funcapp"
    key_vault         = "${local.prefix}-kv"
    static_web_app    = "${local.prefix}-frontend"
    openai            = "${local.prefix}-openai"
    doc_intelligence  = "${local.prefix}-docintel"
    apim              = "${local.prefix}-apim"
    vnet              = "${local.prefix}-vnet"
    nsg               = "${local.prefix}-nsg"
    search            = "${local.prefix}-search"
  }
}
