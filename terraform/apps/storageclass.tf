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

  depends_on = [
    module.ebs_csi_driver,
    module.iam_assumable_role_with_oidc_ebs 

  ]
}
