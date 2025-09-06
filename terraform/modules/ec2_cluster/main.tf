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

# Master Node in AZ 1a
resource "aws_instance" "master_1a" {
  count = 1

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]  # First subnet (1a)
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = base64encode("#!/bin/bash\nyum update -y")

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-master-1a"
    Type = "Master"
    Role = "Kubernetes-Master"
    AZ   = "us-east-1a"
  })
}

# Master Node in AZ 1b
resource "aws_instance" "master_1b" {
  count = 1

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[1]  # Second subnet (1b)
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = base64encode("#!/bin/bash\nyum update -y")

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-master-1b"
    Type = "Master"
    Role = "Kubernetes-Master"
    AZ   = "us-east-1b"
  })
}

# Worker Nodes distributed across subnets
resource "aws_instance" "worker" {
  count = length(var.subnet_ids) * var.instances_per_subnet

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = base64encode("#!/bin/bash\nyum update -y")

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-worker-${count.index + 1}"
    Type = "Worker"
    Role = "Kubernetes-Worker"
    AZ   = count.index % 2 == 0 ? "us-east-1a" : "us-east-1b"
  })
}
