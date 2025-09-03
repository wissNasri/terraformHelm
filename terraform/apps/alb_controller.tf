# terraform/apps/alb_controller.tf

# =================================================================
# 1. DÉCOUVERTE DE L'INFRASTRUCTURE EXISTANTE
# =================================================================

# Variable pour spécifier le nom du cluster à cibler.
# Cela rend le code réutilisable. La valeur par défaut correspond à votre projet.
variable "cluster_name" {
  description = "Le nom du cluster EKS où installer le contrôleur ALB."
  type        = string
  default     = "tws-eks-cluster"
}

# Data source pour trouver le cluster EKS en utilisant son nom.
# Terraform demandera à AWS : "Donne-moi les infos du cluster qui s'appelle 'tws-eks-cluster'".
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# Data source pour trouver le VPC du cluster.
# On utilise l'ID du VPC que la data source précédente nous a donné.
data "aws_vpc" "cluster_vpc" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

# Data source pour obtenir la région AWS actuelle.
# C'est plus propre que de l'extraire de l'ARN.
data "aws_region" "current" {}


# =================================================================
# 2. CRÉATION DU RÔLE IAM POUR LE CONTRÔLEUR ALB
# =================================================================

# La politique IAM qui donne les permissions au contrôleur ALB.
# Le contenu est dans le fichier iam_policy.json (inchangé).
resource "aws_iam_policy" "alb_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  path   = "/"
  policy = file("iam_policy.json")
}

# Le module qui crée le rôle IAM avec la relation de confiance OIDC.
module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.30" # Utiliser une version récente et compatible

  create_role = true
  role_name   = "AmazonEKSLoadBalancerControllerRole-${var.cluster_name}" # Nom de rôle unique

  # CORRECTION DYNAMIQUE :
  # On utilise l'URL du fournisseur OIDC trouvée par la data source.
  # La fonction 'replace' enlève le "https://".
  provider_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "" )

  # On attache la politique IAM créée juste au-dessus.
  role_policy_arns = [
    aws_iam_policy.alb_policy.arn,
  ]

  tags = {
    Cluster = var.cluster_name
    Role    = "alb-controller"
  }
}


# =================================================================
# 3. DÉPLOIEMENT DU CHART HELM POUR LE CONTRÔLEUR ALB
# =================================================================

module "alb_controller" {
  source = "../modules/alb_controller" # Chemin vers votre module local

  # Paramètres du chart Helm (inchangés)
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  app = {
    name          = "aws-load-balancer-controller"
    version       = "1.13.3" # Assurez-vous que cette version est compatible
    chart         = "aws-load-balancer-controller"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }

  # CORRECTION DYNAMIQUE :
  # On utilise 'templatefile' pour injecter les valeurs trouvées par les data sources
  # dans le fichier de valeurs Helm.
  values = [templatefile("${path.module}/helm-values/alb_controller-1.13.3.yaml", {
    replicaCount = 1
    cluster_name = var.cluster_name
    region       = data.aws_region.current.name
    vpc_id       = data.aws_vpc.cluster_vpc.id
  } )]

  # On injecte l'ARN du rôle IAM directement dans le Service Account de Kubernetes.
  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_with_oidc.this_iam_role_arn
    }
  ]
}
