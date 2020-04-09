terraform {
  required_version = "~> 0.12.0"

  backend "local" {}
}

provider "aws" {
  version = "~> 2.0"

  profile = var.aws_profile
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

