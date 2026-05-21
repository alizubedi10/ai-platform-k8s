variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "aws_profile" {
  type    = string
  default = "ai-platform"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}
