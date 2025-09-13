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

  user_data = base64encode("#!/bin/bash\ndnf update -y")

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

  user_data = base64encode("#!/bin/bash\ndnf update -y")

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

# Worker Nodes distributed across subnets (1 worker per AZ, total 2 workers)
resource "aws_instance" "worker" {
  count = 2

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  # Distribute: 1 worker in each AZ
  subnet_id              = count.index == 0 ? var.subnet_ids[0] : var.subnet_ids[1]
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = base64encode("#!/bin/bash\ndnf update -y")

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
    AZ   = count.index == 0 ? "us-east-1a" : "us-east-1b"
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

  user_data = base64encode("#!/bin/bash\ndnf update -y")

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

  user_data = base64encode("#!/bin/bash\ndnf update -y")

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

# Storage Instance in us-east-1c Private Subnet
resource "aws_instance" "storage_1c" {
  count = 1

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[4]  # Private subnet in 1c
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = base64encode("#!/bin/bash\ndnf update -y")

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted   = false
    delete_on_termination = true
  }

    ebs_block_device {
      device_name           = "/dev/sdb"
      volume_type           = "gp2"
      volume_size           = var.volume_size
      encrypted             = false
      delete_on_termination = true
    }

    ebs_block_device {
      device_name           = "/dev/sdc"
      volume_type           = "gp2"
      volume_size           = var.volume_size
      encrypted             = false
      delete_on_termination = true
    }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-storage-1c"
    Type = "Storage"
    Role = "Storage-Server"
    AZ   = "us-east-1c"
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
