# Dans variables.tf ✅
variable "cluster_name" {
  description = "Le nom du cluster EKS cible pour le déploiement des applications."
  type        = string
  default     = "tws-eks-cluster"
}
