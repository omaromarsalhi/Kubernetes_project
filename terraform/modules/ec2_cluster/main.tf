locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 instances distributed across subnets
resource "aws_instance" "cluster" {
  count = length(var.subnet_ids) * var.instances_per_subnet

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  tags = merge(var.tags, {
    Name   = "${local.name_prefix}-private-${count.index + 1}"
    Type   = "Private"
    Subnet = var.subnet_ids[count.index % length(var.subnet_ids)]
  })
}
