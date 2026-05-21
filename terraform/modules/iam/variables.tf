variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "model_artifact_bucket" {
  type = string
}

variable "mlflow_artifact_bucket" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
