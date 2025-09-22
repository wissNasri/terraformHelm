# ===================================================================
# PARTIE 1 : INSTALLATION D'ARGO CD (VOTRE CODE EXISTANT)
# Ce bloc utilise votre module Helm pour installer le chart Argo CD.
# ===================================================================
module "argocd" {
  source = "../modules/alb_controller" # Note: Pensez à renommer ce module en "helm_app" pour plus de clarté future

  wait_for_completion = true
  atomic              = true
  timeout             = 900

  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"

  app = {
    name          = "my-argo-cd"
    description   = "argo-cd"
    version       = "8.1.3"
    chart         = "argo-cd"
    force_update  = true
    recreate_pods = false
    deploy        = 1
  }

  values = [templatefile("${path.module}/helm-values/argocd-values.yaml", {
    serverReplicas = 1
  } )]

  # Vos dépendances existantes restent les mêmes.
  depends_on = [
    module.alb_controller,
    module.iam_assumable_role_with_oidc_alb,
    # module.external_dns # Si vous l'avez, gardez-le
  ]
}

# ===================================================================
# PARTIE 2 : DÉPLOIEMENT DE L'APPLICATION "MÈRE" (BLOC À AJOUTER)
# Ce bloc s'exécute juste après l'installation d'Argo CD.
# Il crée l'application qui gérera toutes les autres.
# ===================================================================
resource "kubernetes_manifest" "app_of_apps_manager" {
  
  # On dit à Terraform d'appliquer le manifeste que vous avez créé.
  # La fonction file() lit le contenu du fichier YAML.
  # La fonction yamldecode() le transforme en une structure que Terraform comprend.
  manifest = yamldecode(file("${path.module}/app-of-apps.yaml"))

  # DÉPENDANCE CRUCIALE :
  # Terraform attendra que le module "argocd" (Partie 1)
  # soit complètement terminé avant d'essayer de créer cette ressource.
  # Cela garantit qu'Argo CD est prêt à recevoir sa première application.
  depends_on = [
    module.argocd
  ]
}
