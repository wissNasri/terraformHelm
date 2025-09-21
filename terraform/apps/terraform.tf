

# terraform/apps/terraform.tf

terraform {
  # Backend pour stocker l'état des applications (add-ons)
  backend "s3" {
    bucket = "terraform-s3-backend-tws-hackathon111"
    key    = "apps/terraform.tfstate"
    region = "us-east-1"
  }

  # Déclaration des providers requis
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    # --- AJOUT NÉCESSAIRE ---
    # Déclarer le provider kubernetes car nous l'utilisons pour argocd_applications.tf
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.1"
    }
    # ------------------------
  }
}

# ===================================================================
# CONFIGURATION DES PROVIDERS
# ===================================================================
provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    # Le provider Helm utilisera le kubeconfig généré par la pipeline
    config_path = "~/.kube/config"
  }
}

# --- AJOUT NÉCESSAIRE ---
# Configurer le provider kubernetes pour qu'il utilise le même kubeconfig
provider "kubernetes" {
  config_path = "~/.kube/config"
}
# ------------------------

