locals {
  ansible_source = "${path.module}/data"
  artifacts_dir  = "${var.artifacts_dir}/${var.name}"

  kubeconfig_name = "kubeconfig"

  endpoint_file_prefix = "ingress_endpoint"

  ansible_variables = {
    tags = var.tags

    name_prefix = "${var.name}-"

    docker_repo = var.docker_repo

    aws_region = var.aws_region

    apps = var.apps

    ingress_alb = {
      chart_version = "1.0.0"
      name          = "alb-ingress"
      namespace     = "kube-system"

      endpoint_file = local.endpoint_file_prefix

      enabled = var.run_on_fargate

      helm_values = {
        rbac = {
          create = true
        }

        image = {
          repository = "docker.io/amazon/aws-alb-ingress-controller"
          tag        = "v1.1.6"
        }

        clusterName = var.name
        awsRegion   = var.aws_region
        awsVpcID    = var.vpc_id

        podLabels = {
          "schedule-type" = "fargate"
        }

        // TODO: remove
        extraEnv = {
          AWS_ACCESS_KEY_ID     = aws_iam_access_key.ansible.id
          AWS_SECRET_ACCESS_KEY = aws_iam_access_key.ansible.secret
        }

        resources = {
          requests = {
            cpu    = "500m"
            memory = "256Mi"
          }
          limits   = {
            cpu    = "2000m"
            memory = "2048Mi"
          }
        }
      }

    }

    ingress_nginx = {
      chart_version = "1.36.1"
      name          = "nginx-ingress"
      namespace     = "kube-system"

      endpoint_file = local.endpoint_file_prefix

      enabled = !var.run_on_fargate

      helm_values = {
        rbac = {
          create = true
        }

        controller = {
          image = {
            repository = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller"
            tag        = "0.30.0"

            #https://github.com/kubernetes/ingress-nginx/issues/4888
            allowPrivilegeEscalation = false
          }

          # https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/configmap.md
          config = {
            disable-ipv6               = "true"
            use-http2                  = "false"
            compute-full-forwarded-for = "true"

            // ssl-dh-param = ""
            ssl-ecdh-curve         = "secp384r1"
            ssl-ciphers            = "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH"
            ssl-protocols          = "TLSv1.2 TLSv1.3"
            ssl-session-cache      = "true"
            ssl-session-cache-size = "10m"
            ssl-session-tickets    = "off"
            ssl-session-timeout    = "10m"

            keep-alive: "1200"
            proxy-stream-timeout: "1200"
            proxy-read-timeout: "600"
            proxy-send-timeout: "600"
            proxy-request-buffering: "off"
            worker-shutdown-timeout: "120s"
          }

          hostNetwork = false

          kind = "Deployment"

          autoscaling = {
            enabled     = true
            minReplicas = 2
            maxReplicas = 5
          }

          podLabels = {
            "schedule-type" = "fargate"
          }

          extraArgs = {
            http-port  = 8080
            https-port = 8443
          }

          containerPort = {
            http  = 8080
            https = 8443
          }

          service = {
            extraArgs     = {
              http  = 80
              https = 443
            }
            containerPort = {
              http  = 8080
              https = 8443
            }
          }

          resources = {
            requests = {
              cpu    = "500m"
              memory = "256Mi"
            }
            limits   = {
              cpu    = "2000m"
              memory = "2048Mi"
            }
          }
        }

        defaultBackend = {
          enabled = true

          image = {
            repository = "k8s.gcr.io/defaultbackend-amd64"
            tag        = "1.5"
          }

          resources = {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits   = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }

    helm = {
      tiller = {
        namespace = "kube-system"
      }
    }
  }

  ansible_environment = {
    AWS_PROFILE    = var.aws_profile
    KUBECONFIG     = "kubeconfig"
    ANSIBLE_CONFIG = "ansible.cfg"
  }
  ansible_inventory   = ""

  ingress_endpoint_prefix = "${local.artifacts_dir}/${local.endpoint_file_prefix}"
}
