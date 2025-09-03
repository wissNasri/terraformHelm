# terraform/apps/ebs_csi_driver.tf

# =================================================================
# 1. CRÉATION DU RÔLE IAM POUR LE DRIVER EBS CSI
# =================================================================

module "iam_assumable_role_with_oidc_ebs" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 2.0"

  create_role = true
  role_name   = "AmazonEKS_EBS_CSI_DriverRole"

  tags = {
    Cluster = var.cluster_name
    Role    = "role-ebs-csi-driver"
  }

  # URL OIDC dynamique (utilise les data sources du fichier data.tf)
  provider_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "" )

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
  ]
}


# =================================================================
# 2. DÉPLOIEMENT DU CHART HELM POUR LE DRIVER EBS CSI
# =================================================================

module "ebs_csi_driver" {
  source = "../modules/alb_controller" # Idéalement, à renommer en "helm_app"

  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"

  app = {
    name          = "aws-ebs-csi-driver"
    description   = "aws-ebs-csi-driver"
    version       = "2.45.1" 
    chart         = "aws-ebs-csi-driver"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }

  # ✅ CORRECT : On utilise templatefile pour lire votre fichier YAML existant
  # et y injecter la valeur de replicaCount.
  values = [templatefile("${path.module}/helm-values/ebs-csi-driver-2.45.1.yaml", {
    replicaCount = 1
  } )]

  # On injecte l'ARN du rôle IAM, ce qui est la configuration la plus importante.
  set = [
    {
      name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_with_oidc_ebs.this_iam_role_arn
    }
  ]
}
