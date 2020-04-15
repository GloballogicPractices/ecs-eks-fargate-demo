terraform {
  required_version = "~> 0.12.0"

  backend "local" {}
}

provider "aws" {
  version = "~> 2.0"

  profile = var.aws_profile
}

provider "archive" {
  version = "~> 1.3"
}

provider "random" {
  version = "~> 2.2"
}

provider "local" {
  version = "~> 1.4"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

provider "kubernetes" {
  version = "~> 1.11"

  alias = "fargate"

  host                   = data.aws_eks_cluster.fargate.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.fargate.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.fargate.token
  load_config_file       = false
}

provider "kubernetes" {
  version = "~> 1.11"

  alias = "ec2"

  host                   = data.aws_eks_cluster.ec2.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.ec2.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.ec2.token
  load_config_file       = false
}

