# Fichier : terraform/apps/argocd.tf (Version Finale et Robuste)

# ===================================================================
# ÉTAPE 1 : INSTALLATION DES CRDs D'ARGO CD UNIQUEMENT
# On installe une première fois le chart en lui demandant de n'installer QUE les CRDs.
# Cela garantit que le type "Application" est connu du cluster avant de continuer.
# ===================================================================
resource "helm_release" "argocd_crds" {
  name             = "my-argo-cd-crds" # Nom de release unique pour les CRDs
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "8.1.3"
  namespace        = "argocd"
  create_namespace = true # On laisse Helm créer le namespace ici

  # On désactive tout sauf l'installation des CRDs
  set { name = "controller.enabled", value = "false" }
  set { name = "server.enabled", value = "false" }
  set { name = "repoServer.enabled", value = "false" }
  set { name = "dex.enabled", value = "false" }
  set { name = "redis.enabled", value = "false" }
  set { name = "notifications.enabled", value = "false" }
  set { name = "applicationSet.enabled", value = "false" }
  set { name = "crds.install", value = "true" }

  # Contrôles de déploiement
  wait              = true
  atomic            = true
  timeout           = 300
  cleanup_on_fail   = true
}

# ===================================================================
# ÉTAPE 2 : INSTALLATION DU RESTE D'ARGO CD + AMORÇAGE GITOPS
# Cette release dépend de la première et installera tous les composants.
# ===================================================================
module "argocd" {
  source = "../modules/alb_controller" # Pensez à renommer ce module en "helm_app"

  wait_for_completion = true
  atomic              = true
  timeout             = 900
  cleanup_on_fail     = true

  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"

  app = {
    name             = "my-argo-cd"
    chart            = "argo-cd"
    version          = "8.1.3"
    force_update     = true
    deploy           = 1
    create_namespace = false # Important : le namespace est déjà créé par la release des CRDs
  }

  values = [templatefile("${path.module}/helm-values/argocd-values.yaml", {
    serverReplicas = 1
  } )]

  # On dit à cette release de ne PAS essayer de réinstaller les CRDs
  set = [
    { name = "crds.install", value = "false" }
  ]

  # DÉPENDANCE CRUCIALE :
  # On attend que la release des CRDs soit terminée avant de continuer.
  depends_on = [
    helm_release.argocd_crds,
    module.alb_controller,
    module.iam_assumable_role_with_oidc_alb,
  ]
}
