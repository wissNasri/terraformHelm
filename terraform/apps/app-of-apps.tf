# Fichier : terraform/apps/app-of-apps.tf

variable "deploy_app_of_apps" {
  description = "Si true, déploie l'application racine App of Apps."
  type        = bool
  default     = false
}

# Note : La variable 'destroy_mode' est déjà définie dans le fichier principal 'variables.tf'
# et est automatiquement disponible pour tous les fichiers .tf du même répertoire.

resource "kubernetes_manifest" "app_of_apps" {
  # === MODIFICATION : Le 'count' dépend maintenant des deux variables ===
  # Se crée si 'deploy_app_of_apps' est vrai ET 'destroy_mode' est faux.
  count    = var.deploy_app_of_apps && !var.destroy_mode ? 1 : 0
  
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

  # Dépendance explicite et propre
  depends_on = [
    module.argocd,
    module.ebs_csi_driver
  ]
}
