variable "cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "gpu_instance_types" {
  type    = list(string)
  default = ["g4dn.xlarge"]
}

variable "desired_size" {
  type    = number
  default = 0
}

variable "min_size" {
  type    = number
  default = 0
}

variable "max_size" {
  type    = number
  default = 5
}

variable "tags" {
  type    = map(string)
  default = {}
}
