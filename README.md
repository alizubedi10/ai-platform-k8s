# AI Platform on Kubernetes — End-to-End Production Stack

A production-grade AI/ML platform deployed on **AWS EKS**, built with Terraform, Helm, and GitHub Actions CI/CD.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                        AWS Cloud                        │
│  ┌──────────────────────────────────────────────────┐   │
│  │                    VPC                           │   │
│  │  ┌─────────────┐     ┌─────────────────────┐    │   │
│  │  │ Public Subnet│     │   Private Subnets   │    │   │
│  │  │  (ALB/NAT)  │     │  EKS Node Groups    │    │   │
│  │  └─────────────┘     │  ┌───────────────┐  │    │   │
│  │                      │  │  GPU Nodes    │  │    │   │
│  │                      │  │  (g4dn/p3)    │  │    │   │
│  │                      │  └───────────────┘  │    │   │
│  │                      │  ┌───────────────┐  │    │   │
│  │                      │  │  CPU Nodes    │  │    │   │
│  │                      │  │  (m5/c5)      │  │    │   │
│  │                      │  └───────────────┘  │    │   │
│  │                      └─────────────────────┘    │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  Supporting: S3, ECR, RDS (MLflow), IAM IRSA, Secrets  │
└─────────────────────────────────────────────────────────┘

Kubernetes Workloads:
  - Model Serving (custom Helm chart, HPA-enabled)
  - MLflow (experiment tracking + model registry)
  - Ray Cluster (distributed training/inference)
  - NVIDIA Device Plugin (GPU scheduling)
  - Cluster Autoscaler
  - AWS Load Balancer Controller
```

## 📁 Repository Structure

```
ai-platform-k8s/
├── .github/workflows/        # GitHub Actions CI/CD
│   ├── terraform.yml         # Plan/Apply on PR + merge
│   ├── helm-deploy.yml       # Helm release pipeline
│   └── ci.yml                # Lint, validate, security scan
├── terraform/
│   ├── modules/
│   │   ├── vpc/              # VPC, subnets, NAT, IGW
│   │   ├── eks/              # EKS cluster + managed node groups
│   │   ├── gpu-nodegroup/    # GPU-optimized node group
│   │   └── iam/              # IRSA roles, policies
│   └── environments/
│       ├── dev/              # Dev environment config
│       └── prod/             # Prod environment config
├── helm/
│   ├── charts/
│   │   ├── model-serving/    # Custom chart for model inference
│   │   ├── mlflow/           # MLflow tracking server
│   │   └── ray-cluster/      # Ray for distributed workloads
│   └── helmfile.yaml         # Declarative release management
├── docs/
│   ├── architecture.md
│   ├── diagrams/
│   └── runbooks/
└── scripts/
    ├── bootstrap.sh          # One-time cluster bootstrap
    └── teardown.sh           # Clean teardown
```

## 🚀 Quick Start

### Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.6 |
| kubectl | >= 1.28 |
| Helm | >= 3.13 |
| AWS CLI | >= 2.x |
| helmfile | >= 0.158 |

### 1. Bootstrap (first time)

```bash
# Configure AWS credentials
aws configure --profile ai-platform

# Initialize and deploy dev environment
cd terraform/environments/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Configure kubectl
aws eks update-kubeconfig \
  --name ai-platform-dev \
  --region us-east-1 \
  --profile ai-platform

# Run bootstrap script (installs cluster add-ons)
../../scripts/bootstrap.sh dev
```

### 2. Deploy Workloads via Helm

```bash
cd helm
helmfile -e dev sync
```

### 3. Access MLflow

```bash
kubectl port-forward svc/mlflow 5000:5000 -n mlflow
# Open http://localhost:5000
```

## 🔐 Security Posture

- **IRSA** (IAM Roles for Service Accounts) — no node-level IAM credentials
- **Private EKS endpoint** in prod; public+private in dev
- **Secrets Manager** integration via External Secrets Operator
- **Network Policies** enforced (Calico)
- **Pod Security Standards** — restricted baseline
- **Trivy** image scanning in CI

## 🌿 Branching & CI/CD

| Branch | Action |
|--------|--------|
| `feature/*` | Terraform `plan` + Helm `lint` |
| `main` | Terraform `apply` to **dev** |
| `release/*` | Terraform `apply` to **prod** (manual approval) |

## 📖 Docs

- [Architecture Deep Dive](docs/architecture.md)
- [Scaling Runbook](docs/runbooks/scaling.md)
- [Incident Response](docs/runbooks/incident-response.md)

## 📄 License

MIT
