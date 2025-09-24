# On ajoute une variable pour contrôler la création de cette ressource
variable "deploy_app_of_apps" {
  description = "Si true, déploie l'application racine App of Apps."
  type        = bool
  default     = false # Par défaut, on ne la déploie pas.
}

resource "kubernetes_manifest" "app_of_apps" {
  # On ajoute un "count" pour activer/désactiver la ressource
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

  depends_on = [
    module.argocd,
    module.elasticsearch
  ]
}
