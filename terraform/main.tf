terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

}


# VPC Module - Networking only
module "vpc" {
  source = "./modules/vpc"
  project_name    = "kubernetes"
  environment     = "dev"
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"

  project_name    = "kubernetes"
  environment     = "dev"
  vpc_id          = module.vpc.vpc_id
  vpc_cidr_block  = module.vpc.vpc_cidr_block
 
}

# Bastion Host Module
module "bastion" {
  source = "./modules/bastion"

  project_name      = "kubernetes"
  environment       = "dev"
  subnet_id         = module.vpc.public_subnet_1a_id
  security_group_id = module.security_groups.bastion_security_group_id
  key_pair_name     = var.key_pair_name

}

# EC2 Cluster Module
module "ec2_cluster" {
  source = "./modules/ec2_cluster"

  project_name         = "kubernetes"
  environment          = "dev"
  subnet_ids           = module.vpc.private_subnet_ids
  security_group_id    = module.security_groups.private_ec2_security_group_id
  key_pair_name        = var.key_pair_name
}
