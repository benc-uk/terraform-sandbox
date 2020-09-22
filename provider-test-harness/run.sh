#!/bin/bash
set -e

echo -e "\n\e[34m╔══════════════════════════════════╗"
echo -e "║\e[32m   Terraform AzureRM Sandbox 🚀\e[34m   ║"
echo -e "╚══════════════════════════════════╝"
echo -e "\n\e[34m»»» ✅ \e[96mChecking pre-reqs\e[0m..."

az > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "\e[31m»»» ⚠️  Azure CLI is not installed! 😥 Please go to http://aka.ms/cli to set it up"
  exit
fi

terraform version > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "\e[31m»»» ⚠️  Terraform is not installed! 😥 Please go to https://www.terraform.io/downloads.html to set it up"
  exit
fi

export SUB_NAME=$(az account show --query name -o tsv)
if [[ -z $SUB_NAME ]]; then
  echo -e "\n\e[31m»»» ⚠️  You are not logged in to Azure!"
  exit
fi
export TENANT_ID=$(az account show --query tenantId -o tsv)

echo -e "\e[34m»»» 🔨 \e[96mAzure details from logged on user \e[0m"
echo -e "\e[34m»»»   • \e[96mSubscription: \e[33m$SUB_NAME\e[0m"
echo -e "\e[34m»»»   • \e[96mTenant:       \e[33m$TENANT_ID\e[0m\n"

read -p " - Are these details correct, do you want to continue (y/n)? " answer
case ${answer:0:1} in
    y|Y )
    ;;
    * )
        echo -e "\e[31m»»» 😲 Deployment canceled\e[0m\n"
        exit
    ;;
esac

PLUGIN_DIR=.
echo -e "\n\e[34m»»» 🧱 \e[96mCopy local terraform-provider-azurerm plugin\e[0m..."
# Just in case, delete local .terraform to be on the safe side
rm -rf .terraform
# Copy plugin from output of `make build` to local path
# Note. the special sub-directory tree needed by Terraform 0.13
mkdir -p $PLUGIN_DIR/registry.terraform.io/hashicorp/azurerm/99.0.0/linux_amd64
cp $(go env GOPATH)/bin/terraform-provider-azurerm $PLUGIN_DIR/registry.terraform.io/hashicorp/azurerm/99.0.0/linux_amd64

# Init with new provider code as a plugin
echo -e "\n\e[34m»»» ✨ \e[96mTerraform init, with plugin dir=$PLUGIN_DIR\e[0m"
terraform init -plugin-dir=$PLUGIN_DIR

# Standard plan & apply
echo -e "\n\e[34m»»» 📜 \e[96mTerraform plan\e[0m...\n"
terraform plan
echo -e "\n\e[34m»»» 🚀 \e[96mTerraform apply\e[0m...\n"
terraform apply -auto-approve