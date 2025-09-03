# Fichier : terraform/apps/provider.tf

# =================================================================
# CONFIGURATION DES PROVIDERS ET DU BACKEND
# =================================================================
# Ce fichier configure la manière dont Terraform se connecte aux
# différentes plateformes (AWS, Kubernetes) et où il stocke son
# fichier d'état (le backend S3).

terraform {
  # 1. Déclaration des providers requis par ce projet.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }

  # 2. Configuration du backend distant pour stocker l'état de manière sécurisée.
  backend "s3" {
    bucket         = "terraform-s3-backend-tws-hackathon111"
    key            = "apps/terraform.tfstate" # Chemin unique pour ce projet
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# 3. Provider AWS : Pour interagir avec les services AWS (ex: créer des rôles IAM).
provider "aws" {
  region = data.aws_region.current.name
}

# 4. Provider Helm : Pour déployer des charts Helm dans le cluster.
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# 5. Provider Kubernetes : Pour gérer des ressources Kubernetes directement.
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
