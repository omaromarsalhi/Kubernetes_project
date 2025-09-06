variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy instances in"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group for EC2 instances"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instances_per_subnet" {
  description = "Number of instances per subnet"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
