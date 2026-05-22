# IRSA role for model serving pods (S3 read access for model artifacts)
module "model_serving_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-model-serving"

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["model-serving:model-serving-sa"]
    }
  }

  tags = var.tags
}

resource "aws_iam_role_policy" "model_serving_s3" {
  name = "model-artifacts-s3-read"
  role = module.model_serving_irsa.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::${var.model_artifact_bucket}",
        "arn:aws:s3:::${var.model_artifact_bucket}/*"
      ]
    }]
  })
}

# IRSA role for MLflow (S3 artifact store + RDS access via Secrets Manager)
module "mlflow_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-mlflow"

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["mlflow:mlflow-sa"]
    }
  }

  tags = var.tags
}

resource "aws_iam_role_policy" "mlflow_s3" {
  name = "mlflow-s3-artifacts"
  role = module.mlflow_irsa.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::${var.mlflow_artifact_bucket}",
          "arn:aws:s3:::${var.mlflow_artifact_bucket}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = ["arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.cluster_name}/mlflow/*"]
      }
    ]
  })
}
