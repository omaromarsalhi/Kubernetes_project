output "instance_id" {
  description = "ID of the bastion host"
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "private_ip" {
  description = "Private IP of the bastion host"
  value       = aws_instance.bastion.private_ip
}
