# terraform/apps/argocd_crds.tf
# DESCRIPTION: Installe les Custom Resource Definitions (CRDs) requises par Argo CD.
#              Cette version utilise yamlsplit pour gérer plusieurs documents YAML.

locals {
  # Contient les 3 CRDs principales sous forme d'une seule chaîne de caractères.
  argocd_crd_manifests = <<-EOT
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
    shortNames:
    - app
    - apps
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
---
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
    shortNames:
    - appset
    - appsets
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
---
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
    shortNames:
    - proj
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
}

# La ressource kubernetes_manifest va maintenant itérer sur chaque document
# séparé par yamlsplit et créer une ressource pour chacun.
resource "kubernetes_manifest" "argocd_crds" {
  for_each = { for k, v in yamlsplit(local.argocd_crd_manifests) : k => v if length(v) > 0 }
  manifest = each.value
}
