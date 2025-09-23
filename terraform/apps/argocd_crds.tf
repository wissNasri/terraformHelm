# Fichier : terraform/apps/argocd_crds.tf

# Étape 1: Rendre les templates des CRDs du chart ArgoCD sans les installer.
data "helm_template" "argocd_crds" {
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.1.3"
  
  # Important: Ne rendre que les CRDs
  include_crds = true
}

# Étape 2: Appliquer chaque CRD rendue comme un manifeste Kubernetes.
resource "kubernetes_manifest" "argocd_crds" {
  for_each = { for k, v in yamlsplit(data.helm_template.argocd_crds.manifest ) : k => v if length(v) > 0 }
  manifest = each.value
}
