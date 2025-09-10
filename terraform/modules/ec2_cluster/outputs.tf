output "instance_ids" {
  description = "IDs of all EC2 instances"
  value       = concat([aws_instance.master_1a[0].id], [aws_instance.master_1b[0].id], aws_instance.worker[*].id, aws_instance.etcd_instance_1a[*].id, aws_instance.etcd_instance_1b[*].id, aws_instance.load_balancer[*].id)
}

output "private_ips" {
  description = "Private IPs of all EC2 instances"
  value       = concat([aws_instance.master_1a[0].private_ip], [aws_instance.master_1b[0].private_ip], aws_instance.worker[*].private_ip, aws_instance.etcd_instance_1a[*].private_ip, aws_instance.etcd_instance_1b[*].private_ip, aws_instance.load_balancer[*].private_ip)
}

output "instance_count" {
  description = "Total number of instances created"
  value       = 2 + length(aws_instance.worker) + length(aws_instance.etcd_instance_1a) + length(aws_instance.etcd_instance_1b) + length(aws_instance.load_balancer)
}

# Master node outputs
output "master_1a_id" {
  description = "ID of master node in AZ 1a"
  value       = aws_instance.master_1a[0].id
}

output "master_1a_private_ip" {
  description = "Private IP of master node in AZ 1a"
  value       = aws_instance.master_1a[0].private_ip
}

output "master_1b_id" {
  description = "ID of master node in AZ 1b"
  value       = aws_instance.master_1b[0].id
}

output "master_1b_private_ip" {
  description = "Private IP of master node in AZ 1b"
  value       = aws_instance.master_1b[0].private_ip
}

# Worker node outputs
output "worker_instance_ids" {
  description = "IDs of all worker nodes"
  value       = aws_instance.worker[*].id
}

output "worker_private_ips" {
  description = "Private IPs of all worker nodes"
  value       = aws_instance.worker[*].private_ip
}

# Additional instance outputs
output "etcd_instance_1a_id" {
  description = "ID of etcd instance in AZ 1a"
  value       = aws_instance.etcd_instance_1a[0].id
}

output "etcd_instance_1a_private_ip" {
  description = "Private IP of etcd instance in AZ 1a"
  value       = aws_instance.etcd_instance_1a[0].private_ip
}

output "etcd_instance_1b_id" {
  description = "ID of etcd instance in AZ 1b"
  value       = aws_instance.etcd_instance_1b[0].id
}

output "etcd_instance_1b_private_ip" {
  description = "Private IP of etcd instance in AZ 1b"
  value       = aws_instance.etcd_instance_1b[0].private_ip
}

# Combined outputs
output "all_instance_ids" {
  description = "IDs of all instances (masters + workers + additional + load balancer)"
  value       = concat([aws_instance.master_1a[0].id], [aws_instance.master_1b[0].id], aws_instance.worker[*].id, aws_instance.etcd_instance_1a[*].id, aws_instance.etcd_instance_1b[*].id, aws_instance.load_balancer[*].id)
}

output "all_private_ips" {
  description = "Private IPs of all instances (masters + workers + additional + load balancer)"
  value       = concat([aws_instance.master_1a[0].private_ip], [aws_instance.master_1b[0].private_ip], aws_instance.worker[*].private_ip, aws_instance.etcd_instance_1a[*].private_ip, aws_instance.etcd_instance_1b[*].private_ip, aws_instance.load_balancer[*].private_ip)
}

output "master_count" {
  description = "Number of master nodes"
  value       = 2
}

output "worker_count" {
  description = "Number of worker nodes"
  value       = length(aws_instance.worker)
}

output "total_instance_count" {
  description = "Total number of instances"
  value       = 2 + length(aws_instance.worker) + length(aws_instance.etcd_instance_1a) + length(aws_instance.etcd_instance_1b) + length(aws_instance.load_balancer)
}

# Load Balancer outputs
output "load_balancer_id" {
  description = "ID of the load balancer instance"
  value       = aws_instance.load_balancer[0].id
}

output "load_balancer_private_ip" {
  description = "Private IP of the load balancer instance"
  value       = aws_instance.load_balancer[0].private_ip
}

output "load_balancer_public_ip" {
  description = "Public IP of the load balancer instance"
  value       = aws_instance.load_balancer[0].public_ip
}
