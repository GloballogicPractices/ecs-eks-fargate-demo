output "cluster_id" {
  value = module.eks.cluster_id
}

output "vpc_tags" {
  value = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

output "apps_endpoints" {
  value = {for app in var.apps : app.name => fileexists("${local.ingress_endpoint_prefix}_${app.name}") ? trimspace(file("${local.ingress_endpoint_prefix}_${app.name}")) : ""}

  depends_on = [
    null_resource.ansible-run,
  ]
}
