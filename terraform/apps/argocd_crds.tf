# terraform/apps/argocd_crds.tf
# DESCRIPTION: Installe les Custom Resource Definitions (CRDs) requises par Argo CD.
#              Cette étape est cruciale et doit s'exécuter avant le chart Helm.

resource "kubernetes_manifest" "argocd_crds" {
  # Ce manifeste contient les définitions pour Application, AppProject, et ApplicationSet.
  # Il est extrait de la documentation officielle d'Argo CD.
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
)
}
