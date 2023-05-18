variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "i2"
}

variable "namespace" {
  type        = string
  description = "The Kubernetes namespace"
}

variable "service_account" {
  type        = string
  description = "The Kubernetes service account"
}

variable "tags" {
  type        = map(string)
  description = "Tags for Loki"
  default = {
  }
}