# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# Bastion Outputs
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = module.bastion.private_ip
}

# EC2 Cluster Outputs
output "ec2_instance_ids" {
  description = "IDs of all EC2 instances"
  value       = module.ec2_cluster.instance_ids
}

output "ec2_private_ips" {
  description = "Private IPs of all EC2 instances"
  value       = module.ec2_cluster.private_ips
}

output "total_instances" {
  description = "Total number of instances created"
  value       = module.ec2_cluster.instance_count
}
