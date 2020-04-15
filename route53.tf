resource "aws_route53_delegation_set" "this" {
  reference_name = var.name
}

resource "aws_route53_zone" "this" {
  name = "${var.dns_name}."

  delegation_set_id = aws_route53_delegation_set.this.id

  tags = local.tags
}

locals {
  apps       = merge(
  {for v in local.apps_ecs_ec2 : "ecs-ec2-${v.name}" => v},
  {for v in local.apps_ecs_fargate : "ecs-fargate-${v.name}" => v},
  {for v in local.apps_eks_ec2 : "eks-ec2-${v.name}" => v},
  {for v in local.apps_eks_fargate : "eks-fargate-${v.name}" => v},
  )
  apps_names = keys(local.apps)

  apps_endpoints = merge(
  {for k, v in module.cluster-ecs-ec2.apps_endpoints : "ecs-ec2-${k}" => v},
  {for k, v in module.cluster-ecs-fargate.apps_endpoints : "ecs-fargate-${k}" => v},
  {for k, v in module.cluster-eks-ec2.apps_endpoints : "eks-ec2-${k}" => v},
  {for k, v in module.cluster-eks-fargate.apps_endpoints : "eks-fargate-${k}" => v},
  )

  apps_hostnames = [for v in aws_route53_record.apps.*.fqdn : "http://${v}"]
}

resource "aws_route53_record" "apps" {
  count = length(local.apps_names)

  zone_id = aws_route53_zone.this.id
  name    = "${local.apps_names[count.index]}."
  type    = local.apps_endpoints[local.apps_names[count.index]] != "" ? "CNAME" : "A"

  records = [
    local.apps_endpoints[local.apps_names[count.index]] != "" ?
    local.apps_endpoints[local.apps_names[count.index]] : "8.8.8.8"
  ]
  ttl     = "60"
}
