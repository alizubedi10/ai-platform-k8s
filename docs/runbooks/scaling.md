# Runbook: Scaling

## Horizontal Pod Autoscaler (HPA)

Model serving is HPA-enabled out of the box. Default thresholds:

| Metric | Target | Min Replicas | Max Replicas |
|--------|--------|-------------|-------------|
| CPU | 70% | 2 | 20 |
| Memory | 80% | 2 | 20 |

### Manually scale model-serving

```bash
kubectl scale deployment model-serving -n model-serving --replicas=5
```

### Check HPA status

```bash
kubectl get hpa -n model-serving
kubectl describe hpa model-serving -n model-serving
```

---

## Cluster Autoscaler

Cluster Autoscaler manages node group scaling automatically.

### Check CA logs

```bash
kubectl logs -n kube-system -l app=cluster-autoscaler -f
```

### Force scale-up (add node)

Schedule a pending pod — CA will react within ~1 minute.

---

## GPU Node Scaling

GPU nodes default to 0 in dev (`desired_size = 0`). To enable:

```bash
# Via Terraform
# Set desired_size = 1 in terraform/environments/dev/main.tf, then apply

# Or directly via AWS CLI
aws eks update-nodegroup-config \
  --cluster-name ai-platform-dev \
  --nodegroup-name ai-platform-dev-gpu \
  --scaling-config minSize=0,maxSize=2,desiredSize=1
```

To schedule a GPU workload (triggers Cluster Autoscaler):

```yaml
resources:
  limits:
    nvidia.com/gpu: 1
tolerations:
  - key: nvidia.com/gpu
    operator: Equal
    value: "true"
    effect: NoSchedule
nodeSelector:
  role: gpu
```

---

## Ray Cluster Scaling

Ray autoscaler handles worker scaling. To adjust min/max workers:

```bash
helm upgrade ray-cluster ./helm/charts/ray-cluster -n ray \
  --set worker.replicas=4
```
