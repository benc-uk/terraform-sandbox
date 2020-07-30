#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

PREFIX="baz2"
IMAGE="bencuk/nodejs-demoapp"

# Load .env as env vars
eval $(egrep -v '^#' .env | xargs)

echo -e "\n\e[34m»»» 🚀 \e[32mLet's go\e[0m...\n"
terraform init -reconfigure -backend=true \
  -backend-config="resource_group_name=$TF_BACKEND_RESGRP" \
  -backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACCOUNT" \
  -backend-config="container_name=$TF_BACKEND_CONTAINER" \
  -backend-config="key=$TF_BACKEND_KEY" \
  -backend-config="subscription_id=$TF_VAR_subscription_id" \
  -backend-config="client_id=$TF_VAR_client_id" \
  -backend-config="client_secret=$TF_VAR_client_secret" \
  -backend-config="tenant_id=$TF_VAR_tenant_id" 

terraform plan -out=tfplan -var "image=$IMAGE" -var "prefix=$PREFIX"

terraform apply -auto-approve tfplan

rm -f tfplan