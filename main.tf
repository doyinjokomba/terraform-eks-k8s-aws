#
# Create EKS Cluster - Entry Point
#


locals {
  eks_vpc_name = "${var.deploy_id_prefix}-${var.vpc_name}"
  eks_cluster_name = "${var.deploy_id_prefix}-${var.cluster_name}"
  eks_nodegroup_one_name = "${var.deploy_id_prefix}-${var.cluster_name}-nodegroup-one"
}

module "eks" {
  source      = "./eks"
 
  cluster_name = local.eks_cluster_name
  nodegroup_one_name = local.eks_nodegroup_one_name
  vpc_subnet_ids = module.vpc.vpc_private_subnet_ids
}

module "vpc" {
  source      = "./vpc"

  vpc_name = local.eks_vpc_name
  tag_cluster_name = local.eks_cluster_name
}
