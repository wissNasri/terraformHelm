# terraform/apps/external_dns.tf (Version Finale Corrigée)

data "aws_route53_zone" "iovision_site" {
  name         = "iovision.site."
  private_zone = false
}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "ExternalDNSPolicyForEKS"
  description = "Permet à ExternalDNS de gérer les enregistrements Route53 pour le cluster EKS."
  policy      = templatefile("${path.module}/external-dns-policy.json", {
    HOSTED_ZONE_ID = data.aws_route53_zone.iovision_site.zone_id
  })
}

module "iam_assumable_role_with_oidc_external_dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 2.0" # CORRECTION 1

  create_role = true
  role_name   = "AmazonEKSExternalDNSRole"

  provider_url = replace(data.aws_iam_openid_connect_provider.oidc_provider.url, "https://", ""  )

  role_policy_arns = [
    aws_iam_policy.external_dns_policy.arn
  ]
}

module "external_dns" {
  source = "../modules/helm_app"

  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/external-dns/"

  app = {
    name          = "external-dns"
    chart         = "external-dns"
    version       = "1.19.0"
    deploy        = 1
  }

  values = [templatefile("${path.module}/helm-values/external-dns-values.yaml", {
    AWS_REGION     = var.aws_region
    HOSTED_ZONE_ID = data.aws_route53_zone.iovision_site.zone_id
  }  )]

  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_with_oidc_external_dns.this_iam_role_arn # CORRECTION 2
    }
  ]

  depends_on = [
    module.iam_assumable_role_with_oidc_external_dns
  ]
}
