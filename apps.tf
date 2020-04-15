locals {
  apps_dir = "${path.root}/apps"

  app_port   = 80
  app_scheme = "HTTP"
  app_ping   = "/ping"

  env_common = {
    DEMO_VERSION = "1.0.0"
    DEMO_BIND    = ":${local.app_port}"
  }

  apps_eks_ec2 = [
    {
      name      = "demo"
      namespace = "default"
      source    = abspath("${local.apps_dir}/demo")

      helm_values = jsonencode({
        resources = {
          requests = {
            memory = "100Mi"
            cpu    = "100m"
          }
          limits   = {
            memory = "100Mi"
            cpu    = "100m"
          }
        }

        http = {
          port   = local.app_port
          scheme = local.app_scheme
          ping   = local.app_ping
        }

        ingress = {
          domain = "eks-ec2-demo.${var.dns_name}"
        }

        extraEnv = [for k, v in merge(local.env_common, {
          DEMO_ENVIRONMENT = "EKS on EC2"
        }) : {
          name: k, value: v
        }]
      })
    }
  ]

  apps_eks_fargate = [
    {
      name      = "demo"
      namespace = "default"
      source    = abspath("${local.apps_dir}/demo")

      helm_values = jsonencode({
        serviceType = "NodePort"

        resources = {
          requests = {
            memory = "100Mi"
            cpu    = "100m"
          }
          limits   = {
            memory = "100Mi"
            cpu    = "100m"
          }
        }

        http = {
          port   = local.app_port
          scheme = local.app_scheme
          ping   = local.app_ping
        }

        ingress = {
          domain = "eks-fargate-demo.${var.dns_name}"
        }

        extraEnv = [for k, v in merge(local.env_common, {
          DEMO_ENVIRONMENT = "EKS on Fargate"
        }) : {
          name: k, value: v
        }]
      })
    }
  ]

  apps_ecs_ec2 = [
    {
      name   = "demo"
      source = abspath("${local.apps_dir}/demo")

      env = merge(local.env_common, {
        DEMO_ENVIRONMENT = "ECS on EC2"
      })
    }
  ]

  apps_ecs_fargate = [
    {
      name   = "demo"
      source = abspath("${local.apps_dir}/demo")

      env = merge(local.env_common, {
        DEMO_ENVIRONMENT = "ECS on Fargate"
      })
    }
  ]
}
