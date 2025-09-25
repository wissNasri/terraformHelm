# Fichier : terraform/apps/variables.tf

variable "aws_region" {
  description = "La région AWS où le cluster EKS est déployé."
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_name" {
  description = "Le nom du cluster EKS cible."
  type        = string
  default     = "tws-eks-cluster"
}

# === AJOUT DE LA NOUVELLE VARIABLE DE CONTRÔLE ===
variable "destroy_mode" {
  description = "Activer ce mode pour forcer la destruction des applications avant l'infrastructure."
  type        = bool
  default     = false
}
