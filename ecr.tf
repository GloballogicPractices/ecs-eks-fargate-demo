resource "aws_ecr_repository" "apps" {
  name = var.name

  tags = local.tags
}
