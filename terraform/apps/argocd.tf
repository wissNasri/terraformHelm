# Fichier : terraform/apps/argocd.tf (Version avec la syntaxe corrigée)

# ===================================================================
# ÉTAPE 1 : INSTALLATION DES CRDs D'ARGO CD UNIQUEMENT
# ===================================================================
resource "helm_release" "argocd_crds" {
  name             = "my-argo-cd-crds"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "8.1.3"
  namespace        = "argocd"
  create_namespace = true

  # ===================================================================
  # SYNTAXE CORRIGÉE : On utilise une liste de blocs 'set'
  # ===================================================================
  set {
    name  = "controller.enabled"
    value = "false"
  }
  set {
    name  = "server.enabled"
    value = "false"
  }
  set {
    name  = "repoServer.enabled"
    value = "false"
  }
  set {
    name  = "dex.enabled"
    value = "false"
  }
  set {
    name  = "redis.enabled"
    value = "false"
  }
  set {
    name  = "notifications.enabled"
    value = "false"
  }
  set {
    name  = "applicationSet.enabled"
    value = "false"
  }
  set {
    name  = "crds.install"
    value = "true"
  }
  # ===================================================================
depends_on = [
  kubernetes_namespace.argocd,
  module.alb_controller,

]
  # Contrôles de déploiement
  wait              = true
  atomic            = true
  timeout           = 300
  cleanup_on_fail   = true
}

# ===================================================================
# ÉTAPE 2 : INSTALLATION DU RESTE D'ARGO CD + AMORÇAGE GITOPS
# (Cette partie reste inchangée )
# ===================================================================
module "argocd" {
  source = "../modules/alb_controller"

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
    create_namespace = false
  }

  values = [templatefile("${path.module}/helm-values/argocd-values.yaml", {
    serverReplicas = 1
  } )]

  set = [
    { name = "crds.install", value = "false" }
  ]

  depends_on = [
    helm_release.argocd_crds,
    module.alb_controller,
    module.iam_assumable_role_with_oidc_alb,
  ]
}
