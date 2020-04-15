locals {
  ansible_source = "${path.module}/data"
  artifacts_dir  = "${var.artifacts_dir}/${var.name}"

  ansible_variables = {
    tags = var.tags

    name_prefix = "${var.name}-"

    cluster_name = aws_ecs_cluster.this.name

    iam_role = aws_iam_role.ecsTaskExecutionRole.arn

    isFargate = var.run_on_fargate

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
