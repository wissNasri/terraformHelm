module kibana {
  source  = "../modules/alb_controller"

  namespace  = "logging"
  repository =  "https://helm.elastic.co"

  app = {
    name          = "kibana"
    description   = "kibana"
    version       = "8.5.1"
    chart         = "kibana"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }
  values = [file("${path.module}/helm-values/kibana.yaml")]
  wait_for_completion = false


}
