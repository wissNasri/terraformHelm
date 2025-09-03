# terraform/apps/data.tf

# =================================================================
# DÉCOUVERTE DE L'INFRASTRUCTURE PARTAGÉE
# =================================================================
# Ce fichier trouve l'infrastructure de base (Cluster, VPC, Région)
# pour que tous les autres modules (ALB, EBS, etc.) puissent l'utiliser.

variable "cluster_name" {
  description = "Le nom du cluster EKS cible pour toutes les applications."
  type        = string
  default     = "tws-eks-cluster"
}

# Data source pour trouver le cluster EKS par son nom.
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# Data source pour trouver le VPC du cluster.
data "aws_vpc" "cluster_vpc" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

# Data source pour obtenir la région AWS actuelle.
data "aws_region" "current" {}
