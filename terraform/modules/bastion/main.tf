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

# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  user_data = base64encode(templatefile("${path.module}/user_data_bastion.sh", {
    ssh_private_key = file("${path.root}/../my-key-pair.pem")
  }))

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted   = false
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-bastion-host"
    Type = "Bastion"
  })
}
