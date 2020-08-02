#!/bin/bash
set -e

echo -e "\n\e[34m»»» ✨ \e[96mTerraform init\e[0m..."
terraform init -input=false \
  -backend-config="resource_group_name=$BACKEND_RESGRP" \
  -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" \
  -backend-config="container_name=$BACKEND_CONTAINER" \

echo -e "\n\e[34m»»» 📜 \e[96mTerraform plan\e[0m...\n"
terraform plan -input=false -out=tfplan $1

echo -e "\n\e[34m»»» 🚀 \e[96mTerraform apply\e[0m...\n"
terraform apply -input=false -auto-approve tfplan