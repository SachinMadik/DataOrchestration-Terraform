#!/bin/bash
# Bootstrap: creates the remote backend storage before terraform init
# Safe to run multiple times — all commands are idempotent

RESOURCE_GROUP="Data-Orchestration-Terraform"
STORAGE_ACCOUNT="dataorchnewstorage"
CONTAINER="deployments"
LOCATION="eastus"

az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID" --output none
az account set --subscription "$ARM_SUBSCRIPTION_ID" --output none

az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku Standard_LRS --output none
az storage container create --name "$CONTAINER" --account-name "$STORAGE_ACCOUNT" --auth-mode login --output none

echo "Bootstrap complete."
