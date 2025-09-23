# Fichier : terraform/apps/argocd_crds.tf
resource "kubernetes_manifest" "crd_applications" {
  manifest = yamldecode(file("${path.module}/crd-manifests/application.yaml"))
}
resource "kubernetes_manifest" "crd_applicationsets" {
  manifest = yamldecode(file("${path.module}/crd-manifests/applicationset.yaml"))
}
resource "kubernetes_manifest" "crd_appprojects" {
  manifest = yamldecode(file("${path.module}/crd-manifests/appproject.yaml"))
}
