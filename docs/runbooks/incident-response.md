# Runbook: Incident Response

## Model Serving Down

### Symptoms
- 5xx from ALB, `/health` returning non-200
- HPA not scaling

### Steps

```bash
# 1. Check pod status
kubectl get pods -n model-serving

# 2. Describe failing pod
kubectl describe pod <pod-name> -n model-serving

# 3. Check logs
kubectl logs <pod-name> -n model-serving --previous

# 4. Check HPA
kubectl describe hpa model-serving -n model-serving

# 5. Check events
kubectl get events -n model-serving --sort-by='.lastTimestamp'
```

### Common Causes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `OOMKilled` | Memory limit too low | Increase `resources.limits.memory` in values.yaml |
| `ImagePullBackOff` | ECR auth failure / wrong tag | Check IRSA role, verify image tag exists |
| `CrashLoopBackOff` | App error on startup | Check app logs, verify S3 model path |
| Pending pods | No schedulable nodes | Check node capacity, CA logs |

---

## MLflow Unreachable

```bash
kubectl get pods -n mlflow
kubectl logs -n mlflow -l app=mlflow

# Check DB connectivity (secret populated?)
kubectl get secret mlflow-db-secret -n mlflow -o jsonpath='{.data}'
```

---

## GPU Node Not Scheduling

```bash
# Check device plugin
kubectl get pods -n kube-system -l name=nvidia-device-plugin-ds

# Check node resources
kubectl describe node <gpu-node-name> | grep -A5 "Allocatable"

# Verify taint
kubectl describe node <gpu-node-name> | grep Taints
```

---

## Escalation

| Severity | Response Time | Owner |
|----------|-------------|-------|
| P1 — prod inference down | 15 min | On-call platform engineer |
| P2 — degraded performance | 1 hr | Platform team |
| P3 — non-prod issue | 1 business day | Platform team |
