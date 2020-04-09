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
      demo_eks_ec2     = {
        name        = "demo-ec2"
        namespace   = var.k8s_namespace_demo_ec2
        helm_values = {
          image = {
            repository = "tutum/hello-world"
          }
        }
      }
      demo_eks_fargate = {
        name        = "demo-fargate"
        image       = "tutum/hello-world"
        namespace   = var.k8s_namespace_demo_fargate
        helm_values = {
          image = {
            repository = "tutum/hello-world"
          }
        }
      }
      demo_fargate     = {
        name    = "demo"
        image   = "tutum/hello-world"
        cluster = aws_ecs_cluster.this.name
        subnets = module.vpc.public_subnets
        ports   = [
          {
            containerPort = 80
            hostPort      = 80
          }
        ]
      }
    }
  }

  ansible_inventory = ""
}
