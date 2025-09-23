# Fichier : terraform/apps/terraform.tf (Version Finale Corrigée)

terraform {
  backend "s3" {
    bucket         = "terraform-s3-backend-tws-hackathon111"
    key            = "apps/terraform.tfstate"
    region         = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# MODIFICATION APPLIQUÉE ICI
provider "kubernetes" {
  config_path = "~/.kube/config"

  # Cette ligne demande au provider de ne pas valider les types de ressources
  # (comme "Application") pendant la phase de plan, ce qui résout l'erreur.
  # La validation se fera au moment de l'apply, lorsque les CRDs existeront.
  validate_resources_on_plan = false
}
