variable "aws_region"       { type = string; default = "us-east-1" }
variable "aws_profile"      { type = string; default = "ai-platform-prod" }
variable "environment"      { type = string; default = "prod" }
variable "vpc_cidr"         { type = string; default = "10.1.0.0/16" }
variable "cluster_version"  { type = string; default = "1.29" }
