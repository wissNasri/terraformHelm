resource "aws_iam_policy" "alb_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path   = "/"
  policy = file("${path.module}/iam_policy.json") # Assurez-vous que ce fichier existe
}


module "iam_assumable_role_with_oidc_alb" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 2.0"

  create_role = true
  role_name   = "AmazonEKSLoadBalancerControllerRole" 

  provider_url = replace(data.aws_iam_openid_connect_provider.oidc_provider.url, "https://", "" )

  role_policy_arns = [ 
      aws_iam_policy.alb_policy.arn, 
]


}

module "alb_controller" {
  source = "../modules/alb_controller" 

  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"

  wait_for_completion = true
  atomic              = true
  timeout             = 600

  app = {
    name          = "aws-load-balancer-controller"
    chart         = "aws-load-balancer-controller"
    version       = "1.13.3" 
    force_update  = true
    recreate_pods = false
    deploy        = 1

  }

  values = [templatefile("${path.module}/helm-values/alb_controller-1.13.3.yaml", {
    cluster_name  = var.eks_cluster_name
    region        = var.aws_region
    vpc_id        = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id 
    replicaCount  = 1
  } )]

  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_with_oidc_alb.this_iam_role_arn
    }
  ]
}
resource "time_sleep" "wait_for_alb_controller" {
  # Cette ressource dépend de la fin de l'installation du chart Helm
  depends_on = [module.alb_controller]

  # On attend 60 secondes. C'est une solution simple mais efficace pour laisser
  # le temps aux pods de démarrer et de devenir "Ready".
  create_duration = "60s"
}
