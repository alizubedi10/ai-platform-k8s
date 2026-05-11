#!/usr/bin/env bash
# teardown.sh — Clean cluster teardown
# Usage: ./scripts/teardown.sh <env>
# ⚠️  This will DESTROY all resources. Use with caution.

set -euo pipefail

ENV=${1:-dev}
CLUSTER_NAME="ai-platform-${ENV}"

echo "⚠️  TEARDOWN: ${CLUSTER_NAME}"
read -rp "Type the cluster name to confirm: " CONFIRM

if [[ "${CONFIRM}" != "${CLUSTER_NAME}" ]]; then
  echo "Aborted."
  exit 1
fi

echo "🧹 Uninstalling Helm releases..."
cd helm
helmfile -e "${ENV}" destroy || true
cd ..

echo "💥 Destroying Terraform..."
cd "terraform/environments/${ENV}"
terraform destroy -auto-approve
cd ../../..

echo "✅ Teardown complete."
