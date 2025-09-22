# terraform/apps/argocd.tf

module "argocd" {
  source  = "../modules/alb_controller"

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
    skip_crds     = true # Ajout important : dit à Helm de ne pas toucher aux CRDs
  }

  values = [templatefile("${path.module}/helm-values/argocd-values.yaml", {
    serverReplicas = 1
  } )]

  depends_on = [
    module.alb_controller,
    module.iam_assumable_role_with_oidc_alb,
    # Ajout important : dépendance explicite sur les CRDs
    kubernetes_manifest.crd_applications,
    kubernetes_manifest.crd_applicationsets,
    kubernetes_manifest.crd_appprojects
  ]
}
