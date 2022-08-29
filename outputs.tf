#
# Create EKS Cluster - Final Output
#

output "cluster_endpoint" {
  description = "Cluster endpoint addresses"
  value = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  description = "Certificate Authority"
  value = module.eks.kubeconfig_certificate_authority_data
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.eks_cluster_name
}
