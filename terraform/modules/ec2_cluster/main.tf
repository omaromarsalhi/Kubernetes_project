locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
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

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_dns_name = var.efs_dns_name
  }))

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted   = false
    delete_on_termination = true
  }

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

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_dns_name = var.efs_dns_name
  }))

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted   = false
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-master-1b"
    Type = "Master"
    Role = "Kubernetes-Master"
    AZ   = "us-east-1b"
  })
}

# Worker Nodes distributed across subnets (2 workers in AZ A, 1 worker in AZ B)
resource "aws_instance" "worker" {
  count = 3  # Total of 3 workers: 2 in AZ A, 1 in AZ B

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  # Distribute: 2 workers in AZ A subnets, 1 worker in AZ B subnet
  subnet_id              = count.index == 0 ? var.subnet_ids[0] : (count.index == 1 ? var.subnet_ids[2] : var.subnet_ids[1])
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_dns_name = var.efs_dns_name
  }))

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted   = false
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-worker-${count.index + 1}"
    Type = "Worker"
    Role = "Kubernetes-Worker"
    AZ   = count.index < 2 ? "us-east-1a" : "us-east-1b"
  })
}

# Additional instances in new subnets
resource "aws_instance" "etcd_instance_1a" {
  count = 1

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[2]  # Additional subnet in 1a
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_dns_name = var.efs_dns_name
  }))

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted   = false
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-additional-1a"
    Type = "Additional"
    Role = "Additional-Instance"
    AZ   = "us-east-1a"
  })
}

resource "aws_instance" "etcd_instance_1b" {
  count = 1

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[3]  # Additional subnet in 1b
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_dns_name = var.efs_dns_name
  }))

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted   = false
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-additional-1b"
    Type = "Additional"
    Role = "Additional-Instance"
    AZ   = "us-east-1b"
  })
}

# Load Balancer Instance in Public Subnet AZ B
resource "aws_instance" "load_balancer" {
  count = 1

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.load_balancer_subnet_id
  vpc_security_group_ids = [var.load_balancer_security_group_id]
  key_name               = var.key_pair_name
  associate_public_ip_address = true

  user_data = base64encode("#!/bin/bash\ndnf update -y\ndnf install -y nginx\nsystemctl enable nginx\nsystemctl start nginx")

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted   = false
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-load-balancer"
    Type = "LoadBalancer"
    Role = "Kubernetes-LoadBalancer"
    AZ   = "us-east-1b"
  })
}
