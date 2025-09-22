# terraform/apps/app-of-apps.tf

resource "kubernetes_manifest" "app_of_apps_root" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "app-of-apps-root"
      "namespace" = "argocd" # Assurez-vous que c'est le bon namespace
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

  # Dépendance explicite pour s'assurer que le chart Argo CD est installé
  # et que ses CRDs sont prêtes avant de tenter de créer cet objet.
  depends_on = [module.argocd]
}
