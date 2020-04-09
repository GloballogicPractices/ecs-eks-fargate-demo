locals {
  artifacts_dir  = "${path.root}/artifacts"
  ansible_source = "${path.module}/ansible"
  ansible_target = "${local.artifacts_dir}/ansible"

  kubeconfig_path = "kubeconfig"

  ansible_variables = {
    helm = {
      tiller = {
        namespace = "kube-system"
      }
    }

    apps = {
      demo_eks_ec2         = {
        name        = "demo-ec2"
        namespace   = var.k8s_namespace_demo_ec2
        helm_values = {}
      }
      demo_eks_fargate = {
        name        = "demo-fargate"
        namespace = var.k8s_namespace_demo_fargate
        helm_values = {}
      }
    }
  }

  ansible_inventory = ""
}
