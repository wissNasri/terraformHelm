module elasticsearch {
  source  = "../modules/alb_controller"

  namespace  = "logging"
  repository =  "https://helm.elastic.co"

  app = {
    name          = "elasticsearch"
    description   = "elasticsearch"
    version       = "8.1.3"
    chart         = "elasticsearch"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }
  values = [templatefile("${path.module}/helm-values/elasticsearch.yaml", {
    serverReplicas = 1
  })]

}
