output "apps_endpoints" {
  value = {for k, app in var.apps : app.name => aws_lb.this[k].dns_name}
}
