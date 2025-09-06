locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# VPC
resource "aws_vpc" "keubernetes_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-vpc"
  })
}
