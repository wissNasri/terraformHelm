# Fichier : terraform/apps/app-of-apps.tf
# DESCRIPTION : Déploie l'application racine "App of Apps" d'Argo CD.

# Variable pour contrôler le déploiement de cette ressource.
variable "deploy_app_of_apps" {
  description = "Si true, déploie l'application racine App of Apps."
  type        = bool
  default     = false
}

resource "kubernetes_manifest" "app_of_apps" {
  # Utilise un 'count' pour activer ou désactiver la création de cette ressource.
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

  # ===================================================================
  # CHANGEMENT CRUCIAL DE DÉPENDANCE
  # ===================================================================
  depends_on = [
    module.argocd,
    
    # Au lieu de dépendre directement de 'module.elasticsearch', on dépend
    # de son hook de nettoyage.
    # Lors d'un 'destroy', Terraform détruira d'abord 'app_of_apps',
    # PUIS 'null_resource.elasticsearch_cleanup_hook' (qui lance le script de désinstallation ),
    # et enfin 'module.elasticsearch'. C'est le bon ordre.
    null_resource.elasticsearch_cleanup_hook
  ]
}
