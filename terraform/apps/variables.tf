# terraform/apps/variables.tf

variable "aws_region" {
  description = "La région AWS où le cluster EKS est déployé."
  type        = string
  default     = "us-east-1" # Assurez-vous que c'est la bonne région
}

variable "eks_cluster_name" {
  description = "Le nom du cluster EKS cible."
  type        = string
  default     = "tws-eks-cluster" # Le nom de votre cluster
}
