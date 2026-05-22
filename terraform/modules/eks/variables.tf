variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "log_retention_days" {
  type        = number
  default     = 30
  description = "Number of days to retain CloudWatch logs"
}

variable "alert_email" {
  type        = string
  description = "Email address to send CloudWatch alerts to"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags applied to all resources"
}