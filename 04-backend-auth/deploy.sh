#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Pretty banner
echo -e "\n\e[34m╔══════════════════════════════════╗"
echo -e "║\e[32m        Terraform Backend \e[34m        ║"
echo -e "║\e[33m           Test Script  \e[34m          ║"
echo -e "╚══════════════════════════════════╝"
echo -e "\e[35m   v0.0.1    🚀  🚀  🚀\n"

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

if [ ! -f "$DIR/.env" ]; then
  echo -e "\e[31m»»» ⚠️  .env file not found, I do hope those BACKEND_ variables are set!"
else
  # Load environmental vars from .env file
  echo -e "\n\e[34m»»» 🧩 \e[96mLoading environmental variables\e[0m..."
  export $(egrep -v '^#' "$DIR/.env" | xargs)
fi

printenv | grep ARM_ | grep -v "SECRET"
set -e
printenv | grep BACKEND_ | grep -v "SECRET"

echo -e "\n\e[34m»»» ✨ \e[96mTerraform init\e[0m..."
terraform init -input=false -reconfigure \
  -backend-config="resource_group_name=$BACKEND_RESGRP" \
  -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" \
  -backend-config="container_name=$BACKEND_CONTAINER" \
  -backend-config="client_id=$BACKEND_CLIENT_ID" \
  -backend-config="client_secret=$BACKEND_CLIENT_SECRET" \
  -backend-config="subscription_id=$BACKEND_CLIENT_SUBID" \
  -backend-config="tenant_id=$BACKEND_CLIENT_TENANTID"

echo -e "\n\e[34m»»» 📜 \e[96mTerraform plan\e[0m...\n"
terraform plan -input=false -out=tfplan -var prefix=foobar

echo -e "\n\e[34m»»» 🚀 \e[96mTerraform apply\e[0m...\n"
terraform apply -input=false -auto-approve tfplan

rm -rf tfplan