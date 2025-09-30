# terraform/apps/metrics-server.tf

module "metrics_server" {
  # On réutilise votre excellent module de déploiement Helm
  source = "../modules/helm_app" # Ou "../modules/helm_app" si vous le renommez

  # Déploiement dans l'espace de noms standard pour les composants système
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"

  # Paramètres de déploiement robustes
  wait_for_completion = true
  atomic              = true
  timeout             = 300 # 5 minutes

  app = {
    name          = "metrics-server"
    chart         = "metrics-server"
    version       = "3.12.1" # Version stable actuelle, vous pouvez l'ajuster
    deploy        = 1
    force_update  = true
    recreate_pods = false
  }

  # On utilise le fichier de valeurs que nous venons de créer
  values = [
    file("${path.module}/helm-values/metrics-server-values.yaml" )
  ]

  # Dépendance : s'assurer que les composants de base sont là si nécessaire.
  # Pour le Metrics Server, il n'y a généralement pas de dépendance forte
  # avec les autres add-ons, mais on peut le lier à l'ALB controller
  # pour s'assurer qu'il est déployé après les composants initiaux.
  depends_on = [
    module.alb_controller
  ]
}
