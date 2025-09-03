output "alb_controller_role_arn" {
  description = "ARN of the ALB Controller IAM role"
  value       = module.iam_assumable_role_with_oidc_alb.this_iam_role_arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL used for IAM roles"
  value       = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
}

output "vpc_id" {
  description = "VPC ID where EKS cluster is deployed"
  value       = data.aws_vpc.cluster_vpc.id
}
