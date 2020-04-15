module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 11.0"

  cluster_name    = var.name
  cluster_version = "1.15"
  subnets         = concat(var.vpc_private_subnets, var.vpc_public_subnets)
  vpc_id          = var.vpc_id

  write_kubeconfig   = true
  config_output_path = "${local.artifacts_dir}/${local.kubeconfig_name}"

  // TODO: https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/
  // https://github.com/kubernetes-sigs/aws-alb-ingress-controller/issues/1092
//  enable_irsa = var.run_on_fargate

  map_roles = var.run_on_fargate ? [
    {
      rolearn  = aws_iam_role.fargate[0].arn
      username = "system:node:{{SessionName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier",
      ]
    },
  ] : []

  worker_groups = var.run_on_fargate ? [] : [
    {
      instance_type        = "t3.medium"
      asg_min_size         = 2
      asg_desired_capacity = 2
      asg_max_size         = 5
    }
  ]

  tags = var.tags
}
