





# terraformHelm/terraform/apps/terraform.tf (Version Corrigée)

# ===================================================================
# 1. UN SEUL BLOC TERRAFORM
#    Ce bloc contient à la fois la configuration du backend ET
#    la déclaration des providers requis.
# ===================================================================
terraform {
  # Backend pour stocker l'état des applications (add-ons)
  backend "s3" {
    bucket         = "terraform-s3-backend-tws-hackathon111"
    key            = "apps/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  # Déclaration des providers requis
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Je remets une version plus stable, ~> 6.0 peut introduire des changements majeurs.
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

# ===================================================================
# 2. LES BLOCS PROVIDER SONT SÉPARÉS ET AU NIVEAU SUPÉRIEUR
#    Ils ne sont PAS à l'intérieur du bloc terraform.
# ===================================================================
provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

