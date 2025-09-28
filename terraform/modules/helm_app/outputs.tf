# Fichier : terraform/modules/helm_app/outputs.tf

output "metadata" {
  description = "Métadonnées de la release Helm déployée."
  value       = var.app["deploy"] ? helm_release.this[0].metadata : null
}
