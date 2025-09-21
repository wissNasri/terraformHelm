# Fichier : terraform/apps/argocd_applications.tf

# ===================================================================
# DÉCLARATION DE L'APPLICATION DE PRODUCTION
# ===================================================================
resource "kubernetes_manifest" "argocd_app_production" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "quiz-app-production"
      "namespace" = "argocd" # Déployé dans le namespace d'ArgoCD
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io"

      ]
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/wissNasri/app.git" # Votre dépôt applicatif
        "targetRevision" = "HEAD"
        "path"           = "kubernetes-manifest" # Surveille ce dossier pour la prod
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "quiz" # Déploie dans ce namespace
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
        "syncOptions" = [
          "CreateNamespace=true" # Crée le namespace 'quiz' si besoin
        ]
      }
    }
  }

  # S'assure qu'ArgoCD est installé avant de créer cette ressource
  depends_on = [module.argocd]
}

# ===================================================================
# DÉCLARATION DE L'APPLICATION DE STAGING
# ===================================================================
resource "kubernetes_manifest" "argocd_app_staging" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "quiz-app-staging"
      "namespace" = "argocd"
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/wissNasri/app.git"
        "targetRevision" = "HEAD"
        "path"           = "kubernetes-manifest-staging" # Surveille ce dossier pour le staging
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "quiz-staging" # Déploie dans ce namespace
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
        "syncOptions" = [
          "CreateNamespace=true" # Crée le namespace 'quiz-staging' si besoin
        ]
      }
    }
  }

  # S'assure qu'ArgoCD est installé avant de créer cette ressource
  depends_on = [module.argocd]
}
