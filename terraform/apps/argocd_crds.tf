# Fichier : terraform/apps/argocd_crds.tf
# DESCRIPTION : Installe les CRDs requises par Argo CD via des ressources distinctes.
#               Cette approche est la plus compatible et la plus fiable.

resource "kubernetes_manifest" "crd_applications" {
  manifest = yamldecode(<<-EOT
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: applications.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: Application
    listKind: ApplicationList
    plural: applications
    shortNames: ["app", "apps"]
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
    served: true
    storage: true
    subresources:
      status: {}
EOT
)
}

resource "kubernetes_manifest" "crd_applicationsets" {
  manifest = yamldecode(<<-EOT
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: applicationsets.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: ApplicationSet
    listKind: ApplicationSetList
    plural: applicationsets
    shortNames: ["appset", "appsets"]
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
    served: true
    storage: true
    subresources:
      status: {}
EOT
)
}

resource "kubernetes_manifest" "crd_appprojects" {
  manifest = yamldecode(<<-EOT
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: appprojects.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: AppProject
    listKind: AppProjectList
    plural: appprojects
    shortNames: ["proj"]
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
    served: true
    storage: true
EOT
)
}
