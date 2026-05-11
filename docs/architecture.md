# Architecture — AI Platform on Kubernetes

## Overview

This platform provides a self-contained AI/ML infrastructure stack on AWS EKS, designed for production model training, experiment tracking, and scalable inference.

---

## Core Components

### Networking (VPC Module)

- **VPC CIDR**: `10.0.0.0/16` (dev) / `10.1.0.0/16` (prod)
- 3 private subnets (EKS nodes) + 3 public subnets (ALB, NAT)
- Single NAT Gateway in dev; one-per-AZ in prod
- Subnets tagged for EKS and Karpenter discovery

### Compute (EKS Module)

| Layer | Details |
|-------|---------|
| Control Plane | EKS managed, private endpoint in prod |
| General Nodes | `m5.xlarge` / `m5.2xlarge`, cluster-autoscaler managed |
| GPU Nodes | `g4dn.xlarge` (dev) / `g4dn.2xlarge` + `p3.2xlarge` (prod) |
| K8s Version | 1.29 |
| Networking | VPC CNI with prefix delegation |

### Storage & Artifacts

- **S3**: Model artifacts + MLflow experiment artifacts
- **RDS PostgreSQL**: MLflow backend store (credentials in Secrets Manager)
- **ECR**: Container image registry

### Identity & Access (IRSA)

All workloads authenticate to AWS via IRSA (IAM Roles for Service Accounts), eliminating node-level credentials:

| Workload | IAM Permissions |
|----------|----------------|
| `model-serving` | S3 `GetObject` on model bucket |
| `mlflow` | S3 read/write on artifact bucket + Secrets Manager |
| `ebs-csi-controller` | EBS volume management |
| `aws-load-balancer-controller` | ELB management |

---

## Workload Architecture

### Model Serving

```
Ingress (ALB)
  └── Service (ClusterIP)
        └── Deployment (2–20 replicas, HPA)
              └── Container: model server
                    - Reads model artifacts from S3
                    - Exposes /health, /ready, /predict
                    - Metrics on :9090 (Prometheus)
```

GPU inference enabled by setting `gpu.enabled: true` and appropriate node selector + tolerations.

### MLflow

```
Ingress (optional, internal ALB)
  └── Service
        └── Deployment (1 replica)
              ├── Backend: RDS PostgreSQL
              └── Artifact Store: S3
```

### Ray Cluster

```
Ray Head (1 pod) — scheduler + dashboard
  └── Ray Workers (N pods, autoscaled)
        - CPU workers: m5.2xlarge
        - GPU workers: g4dn.2xlarge (optional, tainted)
```

---

## CI/CD Flow

```
feature/* branch
  → CI: lint + validate + tfsec + checkov + trivy
  → Terraform plan posted to PR

merge to main
  → Terraform apply → dev
  → Helm deploy → dev (helmfile sync)

merge to release/*
  → Manual approval gate (GitHub Environments)
  → Terraform apply → prod
  → Helm deploy → prod
```

---

## Security Controls

| Control | Implementation |
|---------|---------------|
| No node credentials | IRSA on all service accounts |
| Private cluster API | Private endpoint in prod |
| Secret management | Secrets Manager + External Secrets Operator |
| Network policies | Calico (deny-all default, explicit allow) |
| Image scanning | Trivy in CI (HIGH/CRITICAL block) |
| IaC scanning | tfsec + Checkov in CI |
| Pod security | PodSecurityStandards: restricted |
| Encryption | EBS volumes encrypted, S3 SSE-S3 |

---

## Observability (Recommended Additions)

- **Prometheus + Grafana** — metrics scraping via ServiceMonitor
- **Fluent Bit** — log shipping to CloudWatch / Elasticsearch
- **Jaeger / OpenTelemetry** — distributed tracing for inference requests
- **DCGM Exporter** — GPU utilization metrics
