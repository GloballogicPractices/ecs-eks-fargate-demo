output "apps_endpoints" {
  value = {for app in var.apps : app.name => ""}
}
