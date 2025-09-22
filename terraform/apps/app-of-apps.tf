# terraform/apps/app-of-apps.tf
# DESCRIPTION: Déploie l'application racine "app-of-apps" une fois qu'Argo CD et ses CRDs sont prêts.

resource "kubernetes_manifest" "app_of_apps_root" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "app-of-apps-root"
      "namespace" = "argocd"
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/wissNasri/app.git"
        "targetRevision" = "main"
        "path"           = "applications"
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

  # Dépendance explicite pour s'assurer que le chart Argo CD est bien installé.
  depends_on = [module.argocd]
}
