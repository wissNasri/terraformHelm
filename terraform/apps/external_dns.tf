# Fichier : terraform/apps/external_dns.tf
# DESCRIPTION : Gère le déploiement de l'add-on ExternalDNS, y compris
#               la création du rôle IAM (IRSA) et le déploiement du chart Helm.

# 1. Récupération automatique de l'ID de la zone hébergée "iovision.site".
data "aws_route53_zone" "iovision_site" {
  name         = "iovision.site." # Le point final est important.
  private_zone = false
}

# 2. Création de la politique IAM à partir du modèle JSON.
resource "aws_iam_policy" "external_dns_policy" {
  name        = "ExternalDNSPolicyForEKS"
  description = "Permet à ExternalDNS de gérer les enregistrements Route53 pour le cluster EKS."
  policy      = templatefile("${path.module}/external-dns-policy.json", {
    HOSTED_ZONE_ID = data.aws_route53_zone.iovision_site.zone_id
  })
}

# 3. Création du rôle IAM pour le Service Account (IRSA).
module "iam_assumable_role_with_oidc_external_dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 2.0"

  create_role = true
  role_name   = "AmazonEKSExternalDNSRole"

  # Référence au fournisseur OIDC du cluster EKS.
  provider_url = replace(data.aws_iam_openid_connect_provider.oidc_provider.url, "https://", "" )

  # Attachement de la politique IAM créée ci-dessus.
  role_policy_arns = [
    aws_iam_policy.external_dns_policy.arn
  ]
}

# 4. Déploiement du chart Helm ExternalDNS via votre module générique.
module "external_dns" {
  source = "../modules/alb_controller" # Réutilisation de votre module "helm_app"

  namespace  = "kube-system" # Espace de noms standard pour les composants système.
  repository = "https://kubernetes-sigs.github.io/external-dns/"

  # Paramètres pour le chart Helm.
  app = {
    name          = "external-dns"
    chart         = "external-dns"
    version       = "1.19.0" # Version alignée sur la documentation fournie.
    deploy        = 1
  }

  # Passage des valeurs dynamiques au fichier de valeurs Helm.
  values = [templatefile("${path.module}/helm-values/external-dns-values.yaml", {
    AWS_REGION     = var.aws_region
    HOSTED_ZONE_ID = data.aws_route53_zone.iovision_site.zone_id
  } )]

  # Injection de l'annotation du rôle IAM sur le compte de service.
  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      # ====================================================================
      # CORRECTION DÉFINITIVE APPLIQUÉE ICI
      # Le nom correct de l'output du module est "iam_role_arn".
      # ====================================================================
      value = module.iam_assumable_role_with_oidc_external_dns.iam_role_arn
    }
  ]

  # Assure que le rôle IAM est créé avant de tenter de déployer le chart.
  depends_on = [
    module.iam_assumable_role_with_oidc_external_dns
  ]
}
