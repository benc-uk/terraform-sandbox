#!/bin/bash
set -e

echo -e "\n\e[34m╔════════════════════════════════════════╗"
echo -e "║\e[32m   Terraform Provider Test Harness 🚀\e[34m   ║"
echo -e "╚════════════════════════════════════════╝"

# CHANGE THIS!
AZURERM_SRC=$HOME/forks/terraform-provider-azurerm

# Build the provider if `build` passed to this script
if [[ $1 == "build" ]]; then
  echo -e "\n\e[34m»»» 📦 \e[96mBuilding AzureRM provider\e[0m..."
  pushd $AZURERM_SRC > /dev/null
  go generate ./azurerm/internal/provider/
  go install
  popd
fi

# Set ARM_ varaibles from .env file
export $(egrep -v '^#' .env | xargs)

# Install the local built version of the provider
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

# Optional: enable ALL the logging
#export TF_LOG=debug

# Standard plan & apply
echo -e "\n\e[34m»»» 📜 \e[96mTerraform plan\e[0m...\n"
terraform plan

echo -e "\n\e[34m»»» 🚀 \e[96mTerraform apply\e[0m...\n"
terraform apply -auto-approve