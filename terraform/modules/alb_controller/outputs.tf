# Fichier : terraform/modules/helm_app/outputs.tf

output "metadata" {
  description = "Métadonnées de la release Helm déployée."
  value       = var.app["deploy"] ? helm_release.this[0].metadata : null
}

# AJOUT : Exposer les variables d'entrée en tant que sorties.
output "app" {
  description = "La carte de configuration de l'application qui a été déployée."
  value       = var.app
}

output "namespace" {
  description = "Le namespace dans lequel l'application a été déployée."
  value       = var.namespace
}
