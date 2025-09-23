module kube-prom-stack {
  source  = "../modules/alb_controller"

  wait_for_completion = true
  atomic              = true
  cleanup_on_fail     = true
  timeout             = 1200

  namespace  = "monitoring"
  repository =  "https://prometheus-community.github.io/helm-charts"

  app = {
    name          = "my-kube-prometheus-stack"
    description   = "my-kube-prometheus-stack"
    version       = "72.9.1"
    chart         = "kube-prometheus-stack"
    force_update  = true
    recreate_pods = false
    deploy        = 1
  }

  values = [file("${path.module}/helm-values/kube-prom-stack.yaml")]
  depends_on = [
    module.alb_controller,
    kubernetes_storage_class_v1.example,
    module.iam_assumable_role_with_oidc_alb, # <-- CORRECTION FINALE
    module.iam_assumable_role_with_oidc_ebs,  # <-- CORRECTION FINALE
    module.external_dns # <-- LIGNE AJOUTÉE
    null_resource.wait_for_argo_crds # Ajout de la dépendance


  ]

}
