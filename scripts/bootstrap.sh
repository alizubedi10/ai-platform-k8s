#!/usr/bin/env bash
# bootstrap.sh — One-time cluster setup after Terraform apply
# Usage: ./scripts/bootstrap.sh <env>

set -euo pipefail

ENV=${1:-dev}
CLUSTER_NAME="ai-platform-${ENV}"
REGION="us-east-1"

echo "🚀 Bootstrapping ${CLUSTER_NAME}..."

# 1. Update kubeconfig
aws eks update-kubeconfig \
  --name "${CLUSTER_NAME}" \
  --region "${REGION}"

echo "✅ kubectl configured"

# 2. Verify cluster access
kubectl cluster-info

# 3. Create namespaces
for ns in model-serving mlflow ray monitoring; do
  kubectl get namespace "${ns}" 2>/dev/null || \
    kubectl create namespace "${ns}"
  echo "  ✅ namespace/${ns}"
done

# 4. Install helmfile (if not present)
if ! command -v helmfile &>/dev/null; then
  echo "Installing helmfile..."
  curl -L "https://github.com/helmfile/helmfile/releases/download/v0.161.0/helmfile_linux_amd64.tar.gz" | tar xz
  sudo mv helmfile /usr/local/bin/
fi

# 5. Add Helm repos
helm repo add eks https://aws.github.io/eks-charts
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo add jetstack https://charts.jetstack.io
helm repo update

echo "✅ Helm repos updated"

# 6. Deploy all releases via helmfile
cd helm
helmfile -e "${ENV}" sync
cd ..

echo ""
echo "🎉 Bootstrap complete for ${CLUSTER_NAME}"
echo ""
echo "Next steps:"
echo "  1. Set IRSA role ARNs in helm chart values"
echo "  2. Populate Secrets Manager with DB credentials"
echo "  3. Push your first model to S3"
