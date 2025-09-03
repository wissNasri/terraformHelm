# terraform/apps/variables.tf
variable "cluster_name" {
  description = "Name of the EKS cluster to target"
  type        = string
  # PAS de default ici ! À fournir par l'utilisateur
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
