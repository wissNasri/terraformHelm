# Fichier : terraform/apps/kibana.tf

module "kibana" {
  source  = "../modules/alb_controller"

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
  values = [file("${path.module}/helm-values/kibana.yaml" )]
  
  # CHANGEMENT : Dépend du hook de nettoyage pour garantir le bon ordre de destruction.
  depends_on = [null_resource.elasticsearch_cleanup_hook]
}
