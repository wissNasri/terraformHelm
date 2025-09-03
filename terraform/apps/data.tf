
# Fichier : terraform/apps/data.tf

# =================================================================
# DÉCOUVERTE DE L'INFRASTRUCTURE PARTAGÉE
# =================================================================
# Ce fichier utilise des "data sources" pour trouver les informations
# de l'infrastructure de base (Cluster EKS, VPC, Région).

# Variable pour spécifier le nom du cluster à cibler.
# C'est le seul point d'entrée nécessaire pour que tout le reste fonctionne.
variable "cluster_name" {
  description = "Le nom du cluster EKS cible pour le déploiement des applications."
  type        = string
  default     = "tws-eks-cluster" # Correspond au `local.name` de votre projet d'infrastructure.
}

# 1. Trouve la région AWS dans laquelle Terraform est exécuté.
data "aws_region" "current" {}

# 2. Trouve le cluster EKS en utilisant le nom fourni dans la variable.
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# 3. Trouve le VPC associé au cluster EKS découvert ci-dessus.
data "aws_vpc" "cluster_vpc" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

# 4. Génère un token d'authentification temporaire pour se connecter au cluster.
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}
