output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.keubernetes_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.keubernetes_vpc.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_1a_id" {
  description = "ID of the public subnet in us-east-1a"
  value       = aws_subnet.public_1a.id
}

output "public_subnet_1b_id" {
  description = "ID of the public subnet in us-east-1b"
  value       = aws_subnet.public_1b.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
}

output "private_subnet_1a_id" {
  description = "ID of the private subnet in us-east-1a"
  value       = aws_subnet.private_1a.id
}

output "private_subnet_1b_id" {
  description = "ID of the private subnet in us-east-1b"
  value       = aws_subnet.private_1b.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private_1a.id, aws_subnet.private_1b.id, aws_subnet.private_1a_additional.id, aws_subnet.private_1b_additional.id]
}

output "private_subnet_1a_additional_id" {
  description = "ID of the additional private subnet in us-east-1a"
  value       = aws_subnet.private_1a_additional.id
}

output "private_subnet_1b_additional_id" {
  description = "ID of the additional private subnet in us-east-1b"
  value       = aws_subnet.private_1b_additional.id
}

output "nat_gateway_1a_id" {
  description = "ID of the NAT Gateway in us-east-1a"
  value       = aws_nat_gateway.nat_1a.id
}

output "nat_gateway_1b_id" {
  description = "ID of the NAT Gateway in us-east-1b"
  value       = aws_nat_gateway.nat_1b.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = [aws_nat_gateway.nat_1a.id, aws_nat_gateway.nat_1b.id]
}

output "eip_nat_1a" {
  description = "Elastic IP for NAT Gateway 1a"
  value       = aws_eip.nat_1a.public_ip
}

output "eip_nat_1b" {
  description = "Elastic IP for NAT Gateway 1b"
  value       = aws_eip.nat_1b.public_ip
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = [aws_route_table.private.id]
}