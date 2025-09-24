# Fichier : terraform/modules/helm_app/variables.tf

variable "namespace" {
  description = "Namespace où déployer l'application."
  type        = string
}

variable "app" {
  description = "Une carte décrivant l'application à déployer."
  type        = map(any)
}

variable "repository" {
  description = "Dépôt Helm."
  type        = string
}

variable "repository_config" {
  description = "Configuration du dépôt (authentification)."
  type        = map(any)
  default     = {}
}

variable "values" {
  description = "Liste des fichiers de valeurs pour le chart Helm."
  type        = list(string)
  default     = []
}

variable "set" {
  description = "Bloc de valeurs à définir."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "set_sensitive" {
  description = "Bloc de valeurs sensibles à définir."
  type = list(object({
    path  = string
    value = string
  }))
  default = []
}

# AJOUT : Variable pour gérer les listes complexes
variable "set_list" {
  description = "Bloc de listes de valeurs à définir. Utile pour les structures YAML complexes."
  type = list(object({
    name  = string
    value = list(string)
  }))
  default = []
}

variable "wait_for_completion" {
  description = "Indique si Terraform doit attendre la fin des opérations Helm."
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Délai d'attente en secondes pour les opérations Helm."
  type        = number
  default     = 300
}

variable "atomic" {
  description = "Si true, l'installation est transactionnelle et annulée en cas d'échec."
  type        = bool
  default     = false
}

variable "cleanup_on_fail" {
  description = "Permet à Helm de supprimer les ressources créées en cas d'échec du déploiement."
  type        = bool
  default     = false
}
