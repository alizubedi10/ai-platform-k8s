resource "aws_eks_node_group" "gpu" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-gpu"
  node_role_arn   = aws_iam_role.gpu_node.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.gpu_instance_types  # e.g. ["g4dn.xlarge"]

  ami_type = "AL2_x86_64_GPU"  # Amazon Linux 2 + NVIDIA drivers

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role             = "gpu"
    "nvidia.com/gpu" = "true"
  }

  taint {
    key    = "nvidia.com/gpu"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  tags = merge(var.tags, {
    "k8s.io/cluster-autoscaler/enabled"               = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}"   = "owned"
    "k8s.io/cluster-autoscaler/node-template/label/role" = "gpu"
  })

  depends_on = [
    aws_iam_role_policy_attachment.gpu_worker_node,
    aws_iam_role_policy_attachment.gpu_cni,
    aws_iam_role_policy_attachment.gpu_ecr,
  ]
}

# IAM Role for GPU nodes
resource "aws_iam_role" "gpu_node" {
  name = "${var.cluster_name}-gpu-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "gpu_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.gpu_node.name
}

resource "aws_iam_role_policy_attachment" "gpu_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.gpu_node.name
}

resource "aws_iam_role_policy_attachment" "gpu_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.gpu_node.name
}
