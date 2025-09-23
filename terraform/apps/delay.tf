# Fichier : terraform/apps/delay.tf

resource "null_resource" "wait_for_argo_crds" {
  # Cette ressource ne s'exécute qu'après que Terraform ait tenté d'installer Argo CD.
  depends_on = [module.argocd]

  # Le provisioner exécute une commande sur la machine locale (le runner).
  provisioner "local-exec" {
    # On attend 45 secondes. C'est une pause "brute" pour laisser le temps
    # à l'API Server de Kubernetes d'enregistrer les CRDs installées par le chart Helm.
    command = "echo '--- Waiting 45 seconds for ArgoCD CRDs to become ready... ---' && sleep 45"
  }

  # Ce trigger force la ressource à se ré-exécuter si le module Argo CD change.
  triggers = {
    argocd_version = module.argocd.metadata[0].version
  }
}
