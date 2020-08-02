#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load .env as env vars
eval $(egrep -v '^#' .env | xargs)

echo -e "\e[34m»»» ☁  \e[96mConfigured Azure provider\e[0m..."
echo -e "\e[34m»»» 📦 \e[96mSubscription: \e[33m$ARM_SUBSCRIPTION_ID\e[0m..."

export TF_VAR_prefix="tfbase"
source ../scripts/terraform.sh

rm -f tfplan