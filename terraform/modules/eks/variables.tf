variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "general_instance_types" {
  type    = list(string)
  default = ["m5.xlarge", "m5.2xlarge"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
