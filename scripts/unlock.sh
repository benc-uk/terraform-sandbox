#!/bin/bash
set -e

echo -e "\n\e[34m»»» 🧙‍♂️ \e[32mTerraform init\e[0m..."
terraform init -input=false \
  -backend-config="resource_group_name=$BACKEND_RESGRP" \
  -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" \
  -backend-config="container_name=$BACKEND_CONTAINER" \

echo -e "\n\e[34m»»» 🔓 \e[32mTerraform force-unlock\e[0m..."
terraform force-unlock -force $1
