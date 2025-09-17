
resource "kubernetes_storage_class_v1" "example" {
  metadata {
    name = "ebs-storage-class"
    annotations = {
      "storageclass.kubernetes.io/is-default-class": "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  # --- AJOUT : Dépendance explicite ---
  # Ne détruit cette StorageClass qu'après la destruction des modules qui l'utilisent.
  depends_on = [
    module.elasticsearch,
    # Ajoutez ici tout autre module qui utilise la persistance, par exemple Prometheus.
    module.kube-prom-stack,
    module.argocd
  ]
}
