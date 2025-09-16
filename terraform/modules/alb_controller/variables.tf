# Fichier : terraform/modules/helm_app/variables.tf

variable "namespace" {
  description = "Namespace où déployer l'application."
  type        = string
}

variable "app" {
  description = "Une application à déployer."
  type        = map(any)
}

variable "repository_config" {
  description = "Configuration du dépôt."
  type        = map(any)
  default     = {}
}

variable "values" {
  description = "Valeurs supplémentaires pour le chart."
  type        = list(string)
  default     = []
}

variable "set" {
  description = "Bloc de valeurs avec des chaînes de caractères personnalisées."
  type = list(object({
    name  = string
    value = string
  }))
  default = null
}

variable "set_sensitive" {
  description = "Bloc de valeurs sensibles qui ne seront pas affichées dans le plan."
  type = list(object({
    path  = string
    value = string
  }))
  default = null
}

variable "repository" {
  description = "Dépôt Helm."
  type        = string
}

variable "wait_for_completion" {
  description = "Indique si Terraform doit attendre la fin des opérations Helm (true/false)."
  type        = bool
  default     = true # Par défaut, on attend toujours. C'est plus sûr.
}

variable "timeout" {
  description = "Délai d'attente en secondes pour les opérations Helm."
  type        = number
  default     = 300 # 5 minutes par défaut
}
