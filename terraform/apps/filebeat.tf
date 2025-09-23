module filebeat {
  source  = "../modules/alb_controller"

  wait_for_completion = true
  timeout             = 600

  namespace  = "logging"
  repository =  "https://helm.elastic.co"

  app = {
    name          = "filebeat"
    description   = "filebeat"
    version       = "8.5.1"
    chart         = "filebeat"
    force_update  = true
    recreate_pods = false
    deploy        = 1
  }
  values = [file("${path.module}/helm-values/filebeat.yaml")]

  depends_on = [module.elasticsearch,null_resource.wait_for_argo_crds]
}
