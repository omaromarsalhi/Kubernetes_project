locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# EFS Security Group
resource "aws_security_group" "efs" {
  name        = "${local.name_prefix}-efs-sg"
  description = "Security group for EFS"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-efs-sg"
  })
}

# EFS File System
resource "aws_efs_file_system" "kubernetes_efs" {
  creation_token = "${local.name_prefix}-efs"
  encrypted      = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-efs"
  })
}

# EFS Mount Targets
resource "aws_efs_mount_target" "mount_targets" {
  for_each = toset(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.kubernetes_efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}
