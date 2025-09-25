# Fichier : terraform/apps/app-of-apps.tf (Version Finale Recommandée)

# Variable pour activer/désactiver le déploiement de cette ressource.
variable "deploy_app_of_apps" {
  description = "Si true, déploie l'application racine App of Apps."
  type        = bool
  default     = false
}

resource "kubernetes_manifest" "app_of_apps" {
  # Utilise la variable pour créer ou non la ressource.
  count    = var.deploy_app_of_apps ? 1 : 0
  provider = kubernetes

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "app-of-apps-root"
      "namespace" = "argocd"
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/wissNasri/app.git"
        "targetRevision" = "HEAD"
        "path"           = "argocd-apps-manifests"
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "argocd"
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }

  # === DÉPENDANCE CORRIGÉE ET EXPLICITE ===
  # On déclare que cette ressource dépend directement d'Argo CD (pour exister )
  # et du driver EBS CSI (car les applications enfants auront besoin de créer du stockage).
  # On retire la dépendance inutile à Elasticsearch.
  depends_on = [
    module.argocd,
    module.ebs_csi_driver
  ]
}
