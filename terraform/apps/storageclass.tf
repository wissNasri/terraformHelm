# Fichier : terraform/apps/storageclass.tf
# DESCRIPTION : Crée la StorageClass par défaut pour le provisionnement dynamique des volumes EBS.

resource "kubernetes_storage_class_v1" "example" {
  metadata {
    name = "ebs-storage-class"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  # ===================================================================
  # AJOUT CRUCIAL : Dépendance de destruction
  # ===================================================================
  # La dépendance à ebs_csi_driver est implicite via le nom du provisioner.
  # On ajoute la dépendance explicite au hook de nettoyage pour forcer l'ordre de destruction.
  depends_on = [
    module.ebs_csi_driver,
    null_resource.elasticsearch_cleanup_hook
  ]
}
