module kube-prom-stack {
  source  = "../modules/alb_controller"

  namespace  = "monitoring"
  repository =  "https://prometheus-community.github.io/helm-charts"

  app = {
    name          = "my-kube-prometheus-stack"
    description   = "my-kube-prometheus-stack"
    version       = "72.9.1"
    chart         = "kube-prometheus-stack"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }
  timeout = 1200 // 20 minutes pour être sûr

  values = [file("${path.module}/helm-values/kube-prom-stack.yaml")]
  depends_on = [
    module.alb_controller, 
    module.ebs_csi_driver # <-- AJOUT
  ]

}
