module elasticsearch {
  source  = "../modules/alb_controller"

  namespace  = "logging"
  repository =  "https://helm.elastic.co"

  app = {
    name          = "elasticsearch"
    description   = "elasticsearch"
    version       = "8.5.1"
    chart         = "elasticsearch"
    deploy        = 1
  }
  timeout             = 900
  values = [file("${path.module}/helm-values/elasticsearch.yaml")]


}
