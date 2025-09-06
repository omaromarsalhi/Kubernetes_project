output "instance_ids" {
  description = "IDs of all EC2 instances"
  value       = aws_instance.cluster[*].id
}

output "private_ips" {
  description = "Private IPs of all EC2 instances"
  value       = aws_instance.cluster[*].private_ip
}

output "instance_count" {
  description = "Total number of instances created"
  value       = length(aws_instance.cluster)
}
