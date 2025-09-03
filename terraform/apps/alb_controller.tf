# Fichier : terraform/apps/alb_controller.tf

# =================================================================
# 1. CRÉATION DU RÔLE IAM POUR LE CONTRÔLEUR ALB
# =================================================================

# La politique IAM qui donne les permissions au contrôleur ALB.
resource "aws_iam_policy" "alb_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  path   = "/"
  policy = file("${path.module}/iam_policy.json") # Assurez-vous que ce fichier existe
}

# Le module qui crée le rôle IAM avec la relation de confiance OIDC.
module "iam_assumable_role_with_oidc_alb" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 2.0"

  create_role = true
  role_name   = "AmazonEKSLoadBalancerControllerRole" 

  # URL OIDC dynamique (utilise les data sources du fichier data.tf)
  provider_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "" )

  # On attache la politique IAM créée juste au-dessus.
  role_policy_arns = [ aws_iam_policy.alb_policy.arn ]

  tags = {
    Cluster = var.cluster_name
    Role    = "alb-controller"
  }
}

# =================================================================
# 2. DÉPLOIEMENT DU CHART HELM POUR LE CONTRÔLEUR ALB
# =================================================================

module "alb_controller" {
  source = "../modules/alb_controller" # Votre module local pour Helm

  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"

  app = {
    name          = "aws-load-balancer-controller"
    chart         = "aws-load-balancer-controller"
    version       = "1.13.3" # Version stable et recommandée
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }

  # On utilise 'templatefile' pour injecter les valeurs trouvées par data.tf
  values = [templatefile("${path.module}/helm-values/alb_controller-1.13.3.yaml", {
    cluster_name = var.cluster_name
    region       = data.aws_region.current.name
    vpc_id       = data.aws_vpc.cluster_vpc.id
    replicaCount = 1
  } )]

  # On injecte l'ARN du rôle IAM dans le Service Account de Kubernetes.
  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_with_oidc_alb.this_iam_role_arn
    }
  ]
}
