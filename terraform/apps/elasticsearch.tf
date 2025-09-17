module elasticsearch {
  source  = "../modules/alb_controller"

  wait_for_completion = true
  atomic              = true
  cleanup_on_fail     = true
  timeout             = 1200 # 20 minutes

  namespace  = "logging"
  repository =  "https://helm.elastic.co"

  app = {
    name          = "elasticsearch"
    description   = "elasticsearch"
    version       = "8.5.1"
    chart         = "elasticsearch"
    force_update  = true
    recreate_pods = false
    deploy        = 1
  }
  timeout             = 900
  values = [file("${path.module}/helm-values/elasticsearch.yaml")]
  depends_on = [kubernetes_storage_class_v1.ebs_sc]

}
