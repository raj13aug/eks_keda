variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "i2"
}

variable "namespace" {
  type        = string
  description = "The Kubernetes namespace"
  default     = "keda"
}

variable "service_account" {
  type        = string
  description = "The Kubernetes service account"
  default     = "keda-operator"
}

variable "tags" {
  type        = map(string)
  description = "Tags for Nataraj"
  default = {
  }
}

variable "keda" {
  type        = string
  description = "Keda configuration"
  default     = "2.10.2"
}