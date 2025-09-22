
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

