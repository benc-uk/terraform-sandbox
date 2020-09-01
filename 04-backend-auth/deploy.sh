#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load environmental vars from .env file
export $(egrep -v '^#' .env | xargs)
#printenv | grep ARM_
#printenv | grep BACKEND_

set -e
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
terraform plan -input=false -out=tfplan -var prefix=foobar12

echo -e "\n\e[34m»»» 🚀 \e[96mTerraform apply\e[0m...\n"
terraform apply -input=false -auto-approve tfplan

rm -rf tfplan