terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket         = "ai-platform-tfstate-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "ai-platform-tfstate-lock"
    encrypt        = true
    profile        = "ai-platform"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = local.common_tags
  }
}

locals {
  cluster_name = "ai-plat-${var.environment}"
  common_tags = {
    Project     = "ai-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source       = "../../modules/vpc"
  cluster_name = local.cluster_name
  vpc_cidr     = var.vpc_cidr
  environment  = var.environment
  tags         = local.common_tags
}

module "eks" {
  source             = "../../modules/eks"
  cluster_name       = local.cluster_name
  cluster_version    = var.cluster_version
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = local.common_tags
}

module "gpu_nodegroup" {
  source             = "../../modules/gpu-nodegroup"
  cluster_name       = local.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  gpu_instance_types = ["g4dn.xlarge"]
  desired_size       = 0
  min_size           = 0
  max_size           = 2
  tags               = local.common_tags
}

module "iam" {
  source                 = "../../modules/iam"
  cluster_name           = local.cluster_name
  oidc_provider_arn      = module.eks.oidc_provider_arn
  aws_region             = var.aws_region
  model_artifact_bucket  = "${local.cluster_name}-model-artifacts"
  mlflow_artifact_bucket = "${local.cluster_name}-mlflow-artifacts"
  tags                   = local.common_tags
}

module "cloudwatch" {
  source             = "../../modules/cloudwatch"
  cluster_name       = local.cluster_name
  log_retention_days = 30
  alert_email        = "alizubedi10@gmail.com"
  tags               = local.common_tags
}

resource "aws_s3_bucket" "model_artifacts" {
  bucket = "${local.cluster_name}-model-artifacts"
  tags   = local.common_tags
}

resource "aws_s3_bucket" "mlflow_artifacts" {
  bucket = "${local.cluster_name}-mlflow-artifacts"
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "model_artifacts" {
  bucket = aws_s3_bucket.model_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}