data "aws_eks_cluster" "fargate" {
  name = module.cluster-eks-fargate.cluster_id
}

data "aws_eks_cluster_auth" "fargate" {
  name = module.cluster-eks-fargate.cluster_id
}

data "aws_eks_cluster" "ec2" {
  name = module.cluster-eks-ec2.cluster_id
}

data "aws_eks_cluster_auth" "ec2" {
  name = module.cluster-eks-ec2.cluster_id
}

locals {
  tags = merge(var.tags, {
    Role = "Demo ${var.name}"
  })
}
