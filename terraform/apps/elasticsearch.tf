# Fichier : terraform/apps/elasticsearch.tf
# DESCRIPTION : Déploie le chart Helm d'Elasticsearch et définit un crochet de nettoyage pour la destruction.

# ===================================================================
# DÉFINITION DU MODULE ELASTICSEARCH
# ===================================================================
module "elasticsearch" {
  source = "../modules/alb_controller"

  wait_for_completion = true
  atomic              = true
  cleanup_on_fail     = true
  timeout             = 1200 # 20 minutes

  namespace  = "logging"
  repository = "https://helm.elastic.co"

  app = {
    name          = "elasticsearch"
    description   = "elasticsearch"
    version       = "8.5.1"
    chart         = "elasticsearch"
    force_update  = true
    recreate_pods = false
    deploy        = 1
  }
  values = [file("${path.module}/helm-values/elasticsearch.yaml" )]

  depends_on = [
    kubernetes_storage_class_v1.example,
    module.alb_controller,
    module.ebs_csi_driver,
    module.iam_assumable_role_with_oidc_ebs
  ]
}

# ===================================================================
# RESSOURCE DE NETTOYAGE DÉDIÉE POUR ELASTICSEARCH (HOOK)
# ===================================================================
resource "null_resource" "elasticsearch_cleanup_hook" {

  # Les triggers utilisent les sorties du module pour rester dynamiques.
  triggers = {
    release_name = module.elasticsearch.app.name
    namespace    = module.elasticsearch.namespace
  }

  # Ce bloc ne s'exécute QUE lors d'un 'terraform destroy'.
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "--- [Pre-Destroy Hook] Attempting to gracefully uninstall Helm release: ${self.triggers.release_name} in namespace ${self.triggers.namespace} ---"
      helm uninstall ${self.triggers.release_name} -n ${self.triggers.namespace} --wait --timeout 15m || echo "Helm release '${self.triggers.release_name}' not found or already deleted. Skipping."
      echo "--- [Pre-Destroy Hook] Helm uninstall command for ${self.triggers.release_name} finished. ---"
    EOT
  }

  # Ce hook dépend de la création de la release Helm.
  depends_on = [module.elasticsearch]
}
