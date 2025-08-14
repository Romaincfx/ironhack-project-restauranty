terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95" # Latest 5.x (compatible with EKS module)
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# -----------------------------------------------------------------------------
# VPC MODULE
# -----------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# -----------------------------------------------------------------------------
# EKS CLUSTER
# -----------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.11"

  cluster_name    = "romain-restauranty-cluser"
  cluster_version = "1.30"

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  enable_irsa     = true

  cluster_endpoint_public_access = true
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# -----------------------------------------------------------------------------
# ACCESS CONFIGURATION
# -----------------------------------------------------------------------------
resource "aws_eks_access_entry" "romain_access" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = "arn:aws:iam::438465169137:user/romain"
}

resource "aws_eks_access_policy_association" "romain_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::438465169137:user/romain"

  access_scope {
    type = "cluster"
  }
}

# Allow inbound HTTPS to control plane from your IP
resource "aws_security_group_rule" "eks_control_plane_https_inbound" {
  description              = "Allow HTTPS from my IP"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["147.161.153.26/32"]
  security_group_id        = module.eks.cluster_security_group_id
}

# -----------------------------------------------------------------------------
# NODE GROUP
# -----------------------------------------------------------------------------
module "eks_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "~> 20.11"

  cluster_name    = module.eks.cluster_name
  cluster_service_cidr   = "172.20.0.0/16" 
  cluster_version = module.eks.cluster_version
  subnet_ids      = module.vpc.private_subnets

  name           = "default"
  instance_types = ["t3.medium"]
  desired_size   = 2
  min_size       = 1
  max_size       = 3
}
