module argocd {
  source  = "../modules/alb_controller"

  wait_for_completion = true
  atomic              = true
  timeout             = 900

  namespace  = "argocd"
  repository =  "https://argoproj.github.io/argo-helm"

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
  })]
  depends_on = [
    module.alb_controller,
    module.iam_assumable_role_with_oidc_alb 
  ]


}
