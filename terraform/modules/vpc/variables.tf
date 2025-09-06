variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "kubernetes"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {"Owner" = "OmarSalhi", "Project" = "Kubernetes"}
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
  sensitive   = true
  default     = ""
}
