module kibana {
  source  = "../modules/alb_controller"
  count = var.destroy_mode ? 0 : 1

  namespace  = "logging"
  repository =  "https://helm.elastic.co"

  wait_for_completion = true
  timeout             = 600

  app = {
    name          = "kibana"
    description   = "kibana"
    version       = "8.5.1"
    chart         = "kibana"
    force_update  = true
    recreate_pods = false
    deploy        = 1
    disable_hooks = true
  }
  values = [file("${path.module}/helm-values/kibana.yaml")]
  depends_on = [module.elasticsearch]

}
