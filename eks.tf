data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.name
  cluster_version = "1.15"
  subnets         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  vpc_id          = module.vpc.vpc_id

  write_kubeconfig   = true
  config_output_path = "${local.ansible_target}/${local.kubeconfig_path}"

  map_roles = [
    {
      rolearn  = aws_iam_role.fargate.arn
      username = "system:node:{{SessionName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier",
      ]
    },
  ]

  worker_groups = [
    {
      instance_type = "t3.medium"
      asg_max_size  = 5
    }
  ]
}
