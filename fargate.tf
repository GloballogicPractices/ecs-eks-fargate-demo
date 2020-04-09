resource "aws_eks_fargate_profile" "demo" {
  cluster_name           = module.eks.cluster_id
  fargate_profile_name   = "demo"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = module.vpc.public_subnet_arns

  selector {
    namespace = "demo-fargate"
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.name
}
