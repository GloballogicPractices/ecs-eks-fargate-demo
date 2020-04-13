locals {
  ansible_source = "${path.module}/data"
  artifacts_dir  = "${var.artifacts_dir}/${var.name}"

  ansible_variables = {
    tags = var.tags

    name_prefix = "${var.name}-"

    docker_repo = var.docker_repo

    aws_region = var.aws_region

    apps = var.apps
  }

  ansible_environment = {
    AWS_PROFILE    = var.aws_profile
    ANSIBLE_CONFIG = "ansible.cfg"
  }
  ansible_inventory   = ""
}
