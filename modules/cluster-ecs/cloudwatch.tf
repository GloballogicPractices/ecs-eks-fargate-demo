resource "aws_cloudwatch_log_group" "this" {
  count = length(var.apps)

  name              = "/ecs/${var.name}-${var.apps[count.index].name}"
  retention_in_days = 7

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "this-canary" {
  count = length(var.apps)

  name              = "/ecs/${var.name}-${var.apps[count.index].name}-canary"
  retention_in_days = 7

  tags = var.tags
}
