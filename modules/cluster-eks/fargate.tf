resource "aws_eks_fargate_profile" "this" {
  count = var.run_on_fargate ? 1 : 0

  cluster_name           = module.eks.cluster_id
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.fargate[0].arn
  subnet_ids             = var.vpc_private_subnets

  selector {
    namespace = "default"
  }
}

resource "aws_eks_fargate_profile" "system" {
  count = var.run_on_fargate ? 1 : 0

  cluster_name           = module.eks.cluster_id
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.fargate[0].arn
  subnet_ids             = var.vpc_private_subnets

  selector {
    namespace = "kube-system"
    labels = {
      "schedule-type" = "fargate"
    }
  }
}

