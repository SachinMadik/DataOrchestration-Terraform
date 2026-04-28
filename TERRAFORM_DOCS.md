# Terraform-DataOrch — Project Documentation

**Project:** Azure AI Data Orchestration Platform  
**Target RG:** `Data-Orchestration-Terraform`  
**Do NOT touch:** `Data-Orchestration-RG` (production)  
**Subscription:** `aecb99f2-8133-42cc-9e22-2e66acddf913`  
**Last updated:** 2026-04-28

---

## What This Project Does

Provisions the full Azure infrastructure for the DataOCD AI platform using modular Terraform. The platform lets users upload documents/images/videos, processes them with Azure AI, and enables chat-based querying with chart generation.

---

## Project Structure

```
Terraform-DataOrch/
├── providers.tf          # Azure provider + subscription config
├── locals.tf             # All resource names derived from prefix
├── variables.tf          # Input variables (subscription, location, secrets)
├── main.tf               # Root module — wires all child modules
├── outputs.tf            # Exposes key URLs and endpoints
├── TERRAFORM_DOCS.md     # This file
└── modules/
    ├── resource-group/   # Azure Resource Group
    ├── monitoring/       # Log Analytics + Application Insights
    ├── storage/          # Storage Account + Blob Containers
    ├── networking/       # VNet + Subnet + NSG
    ├── keyvault/         # Key Vault + Secrets
    ├── ai-services/      # OpenAI + Doc Intelligence + Model Deployments
    ├── search/           # Azure AI Search (free tier)
    ├── compute/          # Flex-Consumption Plan + Function App
    ├── api-management/   # APIM + API + Operations + CORS Policy
    └── frontend/         # Static Web App
```

---

## Naming Convention

All names use prefix `dataorch-new` to avoid conflicts with existing `DataOrchestration-TF` resources.

| Resource | Name |
|---|---|
| Resource Group | `Data-Orchestration-Terraform` |
| Storage Account | `dataorchnewstorage` |
| Log Analytics | `dataorch-new-law` |
| App Insights | `dataorch-new-appinsights` |
| App Service Plan | `dataorch-new-asp` |
| Function App | `dataorch-new-funcapp` |
| Key Vault | `dataorch-new-kv` |
| Static Web App | `dataorch-new-frontend` |
| OpenAI | `dataorch-new-openai` |
| Doc Intelligence | `dataorch-new-docintel` |
| APIM | `dataorch-new-apim` |
| VNet | `dataorch-new-vnet` |
| NSG | `dataorch-new-nsg` |

---

## Dependency Chain

Terraform resolves dependencies via module output references. The order is:

```
resource-group
    ↓ (name, location)
monitoring
    ↓ (app_insights_connection_string)
storage
    ↓ (storage_account_name, primary_access_key, primary_connection_string)
networking
    ↓ (vnet_id, subnet_id, nsg_id)
ai-services
    ↓ (openai_endpoint, openai_api_key, doc_intelligence_endpoint, doc_intelligence_key)
keyvault          ← receives secrets from storage + ai-services
    ↓
compute           ← depends on storage + ai-services + monitoring
    ↓ (function_app_hostname)
api-management    ← depends on compute (uses function_app_hostname as backend URL)
    ↓ (gateway_url)
frontend          ← Static Web App (independent, but logically last)
```

---

## Module Details

### `resource-group`
**Creates:** `azurerm_resource_group`  
**Inputs:** `name`, `location`  
**Outputs:** `name`, `location`  
**Why:** All other modules need the RG name and location.

---

### `monitoring`
**Creates:** `azurerm_log_analytics_workspace`, `azurerm_application_insights`  
**Inputs:** `resource_group_name`, `location`, `law_name`, `app_insights_name`  
**Outputs:** `app_insights_connection_string`, `app_insights_instrumentation_key`  
**Why:** App Insights is linked to Log Analytics (workspace-based). The connection string is passed to the Function App for telemetry.

---

### `storage`
**Creates:** `azurerm_storage_account`, containers: `deployments`, `uploads`  
**Inputs:** `resource_group_name`, `location`, `storage_account_name`  
**Outputs:** `storage_account_name`, `storage_account_id`, `primary_access_key`, `primary_connection_string`  
**Tier:** Standard LRS (free-tier eligible)  
**Why:** Function App needs storage for runtime state. `deployments` container holds the function zip. `uploads` holds user files.

---

### `networking`
**Creates:** `azurerm_virtual_network`, `azurerm_subnet` (function-subnet), `azurerm_network_security_group`  
**Inputs:** `resource_group_name`, `location`, `vnet_name`, `nsg_name`  
**Outputs:** `vnet_id`, `function_subnet_id`, `nsg_id`  
**NSG Rules:** Allow HTTPS (443) inbound, Deny all else  
**Why:** Network isolation for the platform. VNet address space: `10.0.0.0/16`, subnet: `10.0.2.0/24`.

---

### `keyvault`
**Creates:** `azurerm_key_vault`, secrets: `storage-connection-string`, `openai-api-key`, `docintel-api-key`  
**Inputs:** `resource_group_name`, `location`, `key_vault_name`, `tenant_id`, secrets from storage + ai modules  
**Outputs:** `vault_uri`, `vault_id`  
**Tier:** Standard SKU, soft-delete retention 7 days  
**Why:** Centralises secrets. Receives outputs from storage and ai-services modules so secrets are never hardcoded.

---

### `ai-services`
**Creates:**
- `azurerm_cognitive_account` (OpenAI, SKU: S0)
- `azurerm_cognitive_deployment` — `text-embedding-3-small` (capacity: 50)
- `azurerm_cognitive_deployment` — `gpt-4.1-mini` v2025-04-14 (capacity: 50, depends_on embedding)
- `azurerm_cognitive_account` (FormRecognizer / Doc Intelligence, SKU: **F0** free tier)

**Inputs:** `resource_group_name`, `location`, `openai_name`, `doc_intelligence_name`  
**Outputs:** `openai_endpoint`, `openai_api_key`, `doc_intelligence_endpoint`, `doc_intelligence_key`  
**Why:** GPT-4.1-mini for RAG/chat, text-embedding-3-small for vector search, Doc Intelligence for OCR. Embedding deployed first (`depends_on`) to avoid APIM quota conflicts.

---

### `search`
**Creates:** `azurerm_search_service` (SKU: **free**)  
**Inputs:** `resource_group_name`, `location`, `search_service_name`  
**Outputs:** `endpoint` (`https://<name>.search.windows.net`), `primary_key`  
**Why:** Azure AI Search powers the vector + hybrid RAG pipeline. Free tier (1 index, 50MB storage) is sufficient for demo. Endpoint and key are passed directly to the `compute` module as `AZURE_SEARCH_ENDPOINT` and `AZURE_SEARCH_KEY`.

---

### `compute`
**Creates:** `azurerm_service_plan` (FC1 Flex Consumption), `azurerm_linux_function_app` (Python 3.10)  
**Inputs:** All secrets and endpoints from storage, monitoring, ai-services modules  
**Outputs:** `function_app_hostname`, `function_app_id`  
**Plan SKU:** `FC1` — Flex Consumption (pay-per-execution, scales to zero)  
**Why:** FC1 replaces the old Y1 consumption plan. It supports faster cold starts and per-instance concurrency. `WEBSITE_RUN_FROM_PACKAGE=1` enables zip deploy from storage.

**App Settings injected:**
| Setting | Source |
|---|---|
| `AZURE_STORAGE_CONNECTION_STRING` | `module.storage.primary_connection_string` |
| `AZURE_OPENAI_ENDPOINT` | `module.ai_services.openai_endpoint` |
| `AZURE_OPENAI_API_KEY` | `module.ai_services.openai_api_key` |
| `AZURE_OPENAI_DEPLOYMENT_NAME` | `"gpt-4.1-mini"` (hardcoded) |
| `AZURE_OPENAI_EMBEDDING_DEPLOYMENT` | `"text-embedding-3-small"` (hardcoded) |
| `DOC_INTELLIGENCE_ENDPOINT` | `module.ai_services.doc_intelligence_endpoint` |
| `DOC_INTELLIGENCE_KEY` | `module.ai_services.doc_intelligence_key` |
| `AZURE_SEARCH_ENDPOINT` | `module.search.endpoint` |
| `AZURE_SEARCH_KEY` | `module.search.primary_key` |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | `module.monitoring.app_insights_connection_string` |
| `JWT_SECRET` | `var.jwt_secret` |

---

### `api-management`
**Creates:** `azurerm_api_management` (Consumption_0 — free tier), APIM API, 3 operations (GET/POST/DELETE wildcard), CORS policy  
**Inputs:** `resource_group_name`, `location`, `apim_name`, `publisher_name`, `publisher_email`, `function_app_hostname`  
**Outputs:** `gateway_url`, `apim_id`  
**Backend URL:** `https://<function_app_hostname>/api`  
**CORS:** Allow all origins (`*`), all headers, methods: GET/POST/PUT/DELETE/OPTIONS  
**Why:** APIM acts as the single entry point for the frontend. Consumption tier has no fixed cost.

---

### `frontend`
**Creates:** `azurerm_static_web_app`  
**Inputs:** `resource_group_name`, `location` (eastus2), `static_web_app_name`  
**Outputs:** `hostname`, `static_web_app_id`  
**Tier:** Free  
**Location:** `eastus2` (Static Web Apps have limited region availability)  
**Why:** Hosts the React (Vite) SPA. The frontend calls APIM gateway URL as its API backend.

---

## How Terraform Handles Dependencies

### Implicit (reference-based) — used everywhere
When module B uses an output from module A, Terraform automatically creates A before B:
```hcl
module "compute" {
  storage_account_name = module.storage.storage_account_name  # implicit dep on storage
  openai_endpoint      = module.ai_services.openai_endpoint   # implicit dep on ai-services
}
```

### Explicit (`depends_on`) — used inside ai-services
```hcl
resource "azurerm_cognitive_deployment" "gpt" {
  depends_on = [azurerm_cognitive_deployment.embedding]  # deploy embedding first
}
```

---

## Free Tier Resources Used

| Resource | Free Tier |
|---|---|
| Function App | FC1 Flex Consumption (pay per execution, ~1M free calls/month) |
| Static Web App | Free tier |
| APIM | Consumption_0 (free, pay per call) |
| Doc Intelligence | F0 (free tier, 500 pages/month) |
| Storage | Standard LRS (cheapest, ~$0.02/GB) |
| Log Analytics | PerGB2018 (5GB/day free) |
| Key Vault | Standard (10,000 ops/month free) |

> **Note:** OpenAI (S0) and App Insights are not free but are the minimum required SKUs.

---

## Root Outputs

After `terraform apply`, these values are available:

| Output | Description |
|---|---|
| `resource_group_name` | `Data-Orchestration-Terraform` |
| `function_app_url` | `https://dataorch-new-funcapp.azurewebsites.net` |
| `apim_gateway_url` | APIM gateway URL (use as `VITE_AZURE_API_URL` in frontend) |
| `frontend_hostname` | Static Web App hostname |
| `storage_account_name` | For uploading function zip |
| `key_vault_uri` | Key Vault URL |
| `openai_endpoint` | OpenAI endpoint |
| `doc_intelligence_endpoint` | Doc Intelligence endpoint |
| `app_insights_connection_string` | (sensitive) |

---

## Deployment Scripts (scripts/)

### `deploy.sh` — One-click full deploy
1. Runs `build-backend.sh` → packages Python function as zip
2. Runs `build-frontend.sh` → builds React app
3. Runs `terraform init && terraform apply -auto-approve`
4. Uploads `funcapp.zip` to storage `deployments` container
5. Deploys frontend dist to Static Web App

### `build-backend.sh`
- Installs Python deps into `.python_packages/`
- Zips the function app directory
- Output: `/tmp/funcapp.zip`

### `build-frontend.sh`
- Runs `npm ci && npm run build`
- Injects `VITE_AZURE_API_URL` from Terraform output
- Output: `frontend/dist/`

---

## How to Run

```bash
cd Terraform-DataOrch

# First time
terraform init

# Preview changes
terraform plan

# Deploy everything
terraform apply -auto-approve

# One-click (infra + code)
bash scripts/deploy.sh

# Destroy (careful!)
terraform destroy
```

---

## Status

| Task | Status |
|---|---|
| providers.tf | ✅ Done |
| locals.tf | ✅ Done |
| variables.tf | ✅ Done |
| outputs.tf | ✅ Done |
| main.tf (root) | ✅ Done |
| module: resource-group | ✅ Done |
| module: monitoring | ✅ Done |
| module: storage | ✅ Done |
| module: networking | ✅ Done |
| module: keyvault | ✅ Done |
| module: ai-services | ✅ Done |
| module: compute (FC1) | ✅ Done |
| module: api-management | ✅ Done |
| module: frontend | ✅ Done |
| scripts/deploy.sh | ⏳ Pending |
| scripts/build-backend.sh | ⏳ Pending |
| scripts/build-frontend.sh | ⏳ Pending |
| terraform validate | ⏳ Pending |
