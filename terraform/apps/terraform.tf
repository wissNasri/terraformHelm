terraform {
  # Backend pour stocker l'état des applications (add-ons)
  backend "s3" {
    # Le même bucket que pour l'infrastructure
    bucket = "terraform-s3-backend-tws-hackathon111" 
    
    # ===================================================================
    #              LA CLÉ DU SUCCÈS EST ICI
    # Un chemin différent pour le fichier d'état de ce projet.
    # ===================================================================
    key    = "apps/terraform.tfstate"
    
    region = "us-east-1"
    
    # On utilise la même table DynamoDB pour le verrouillage
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.37.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
