# Fichier : terraform/apps/ebs_csi_driver.tf
# DESCRIPTION : Déploie le driver AWS EBS CSI et son rôle IAM associé.
# VERSION FINALE 2.0 : Utilise yamlencode pour injecter correctement les permissions RBAC.

module "iam_assumable_role_with_oidc_ebs" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 2.0"

  create_role = true
  role_name   = "AmazonEKS_EBS_CSI_DriverRole"

  tags = {
    Cluster = var.eks_cluster_name
    Role    = "role-ebs-csi-driver"
  }

  provider_url = replace(data.aws_iam_openid_connect_provider.oidc_provider.url, "https://", ""  )

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
  ]
}

module "ebs_csi_driver" {
  source = "../modules/alb_controller"

  wait_for_completion = true
  atomic              = true
  timeout             = 600
  namespace           = "kube-system"
  repository          = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"

  app = {
    name          = "aws-ebs-csi-driver"
    description   = "aws-ebs-csi-driver"
    version       = "2.45.1" 
    chart         = "aws-ebs-csi-driver"
    force_update  = true
    recreate_pods = false
    deploy        = 1
  }

  values = [templatefile("${path.module}/helm-values/ebs-csi-driver-2.45.1.yaml", {
    replicaCount = 1
  } )]

  set = [
    {
      name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_with_oidc_ebs.this_iam_role_arn
    },
    # ===================================================================
    # CORRECTION FINALE : Injection de la règle RBAC en utilisant yamlencode
    # ===================================================================
    # Au lieu de définir chaque clé individuellement, nous construisons l'objet
    # YAML complet et le passons en une seule fois. C'est la méthode correcte
    # pour les structures de données complexes (listes d'objets).
    {
      name  = "sidecars.provisioner.additionalClusterRoleRules"
      value = yamlencode([
        {
          apiGroups = [""]
          resources = ["persistentvolumes"]
          verbs     = ["get", "list", "watch", "patch"]
        }
      ])
    }
  ]
}
