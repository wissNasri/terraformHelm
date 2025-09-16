# terraform/apps/data.tf

# Récupère les informations du cluster EKS existant
data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}


# Récupère l'URL du fournisseur OIDC du cluster
# L'URL est extraite et le "https://" est retiré
data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
