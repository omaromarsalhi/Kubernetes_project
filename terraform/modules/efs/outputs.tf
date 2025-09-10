output "efs_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.kubernetes_efs.id
}

output "efs_arn" {
  description = "ARN of the EFS file system"
  value       = aws_efs_file_system.kubernetes_efs.arn
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.kubernetes_efs.dns_name
}

output "efs_security_group_id" {
  description = "ID of the EFS security group"
  value       = aws_security_group.efs.id
}

output "mount_target_ids" {
  description = "IDs of the EFS mount targets"
  value       = [for mt in aws_efs_mount_target.mount_targets : mt.id]
}

output "mount_target_ips" {
  description = "IP addresses of the EFS mount targets"
  value       = [for mt in aws_efs_mount_target.mount_targets : mt.ip_address]
}
