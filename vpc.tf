module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 2.33"

  name = var.name
  cidr = var.cidr
  azs  = var.aws_zones

  enable_nat_gateway   = length(var.private_subnets_cidrs) > 0
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true


  private_subnets     = var.private_subnets_cidrs
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnets     = var.public_subnets_cidrs
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  tags = merge(local.tags, {
    Name = var.name
  }, module.cluster-eks-fargate.vpc_tags, module.cluster-eks-ec2.vpc_tags)
}
