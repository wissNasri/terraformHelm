# Fichier : terraform/apps/data.tf

# =================================================================
# DÉCOUVERTE DE L'INFRASTRUCTURE PARTAGÉE
# =================================================================
# Ce fichier utilise des "data sources" pour trouver les informations
# de l'infrastructure de base (Cluster EKS, VPC, Région).

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
# Data source pour récupérer la région AWS dynamiquement
data "aws_region" "current" {}
