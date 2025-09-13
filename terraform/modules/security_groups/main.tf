locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-bastion-sg"
  })
}

# Security Group for Private EC2 instances
resource "aws_security_group" "private_ec2" {
  name        = "${local.name_prefix}-private-ec2-sg"
  description = "Security group for private EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description = "All traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-ec2-sg"
  })
}

# Security Group for Load Balancer
resource "aws_security_group" "load_balancer" {
  name        = "${local.name_prefix}-load-balancer-sg"
  description = "Security group for load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description = "HAProxy Stats from Bastion"
    from_port   = 8399
    to_port     = 8399
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description = "HAProxy Stats from External"
    from_port   = 8399
    to_port     = 8399
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ETCD client access via HAProxy"
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API access via HAProxy"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes Dashboard via HAProxy"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Simple App via HAProxy"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Mongo Express via HAProxy"
    from_port   = 30081
    to_port     = 30081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-load-balancer-sg"
  })
}

# Allow Load Balancer to access Private instances
resource "aws_security_group_rule" "lb_to_private_etcd" {
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2.id
  source_security_group_id = aws_security_group.load_balancer.id
  description              = "ETCD access from Load Balancer"
}

resource "aws_security_group_rule" "lb_to_private_kube" {
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2.id
  source_security_group_id = aws_security_group.load_balancer.id
  description              = "Kubernetes API access from Load Balancer"
}

# Allow Load Balancer to access Dashboard NodePort on masters
resource "aws_security_group_rule" "lb_to_dashboard_nodeport" {
  type                     = "ingress"
  from_port                = 32443
  to_port                  = 32443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2.id
  source_security_group_id = aws_security_group.load_balancer.id
  description              = "Dashboard NodePort access from Load Balancer"
}

# Allow Load Balancer to access Simple App NodePort on masters
resource "aws_security_group_rule" "lb_to_simple_app_nodeport" {
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2.id
  source_security_group_id = aws_security_group.load_balancer.id
  description              = "Simple App NodePort access from Load Balancer"
}

# Allow Load Balancer to access Mongo Express NodePort on masters
resource "aws_security_group_rule" "lb_to_mongo_express_nodeport" {
  type                     = "ingress"
  from_port                = 30081
  to_port                  = 30081
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2.id
  source_security_group_id = aws_security_group.load_balancer.id
  description              = "Mongo Express NodePort access from Load Balancer"
}

# Allow ETCD peer communication between ETCD nodes
resource "aws_security_group_rule" "etcd_peer_communication" {
  type                     = "ingress"
  from_port                = 2380
  to_port                  = 2380
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2.id
  source_security_group_id = aws_security_group.private_ec2.id
  description              = "ETCD peer communication between nodes"
}

# Allow ETCD client communication between ETCD nodes (required for cluster operations)
resource "aws_security_group_rule" "etcd_client_internal" {
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2.id
  source_security_group_id = aws_security_group.private_ec2.id
  description              = "ETCD client communication between nodes"
}

# Allow Bastion to access ETCD for debugging
resource "aws_security_group_rule" "bastion_to_etcd_client" {
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "ETCD client access from Bastion for debugging"
}

# Allow Bastion to access ETCD peer port for debugging
resource "aws_security_group_rule" "bastion_to_etcd_peer" {
  type                     = "ingress"
  from_port                = 2380
  to_port                  = 2380
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "ETCD peer access from Bastion for debugging"
}
