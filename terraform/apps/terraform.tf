# Fichier : terraform/apps/terraform.tf

terraform {
  backend "s3" {
    bucket         = "terraform-s3-backend-tws-hackathon1111"
    key            = "apps/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt = true
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

# MODIFICATION IMPORTANTE
provider "kubernetes" {
  config_path = "~/.kube/config"

  # Empêche Terraform de valider les CRDs pendant le 'plan'
}
