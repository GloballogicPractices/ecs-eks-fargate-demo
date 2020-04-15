resource "aws_ecs_cluster" "this" {
  name = var.name

  tags = var.tags
}

resource "aws_ecs_task_definition" "stub" {
  container_definitions = file("${path.module}/templates/td.json")

  family = "${var.name}-stub"

  requires_compatibilities = var.run_on_fargate ? ["FARGATE"] : []

  network_mode = "awsvpc"

  cpu    = "256"
  memory = "512"

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  count = length(var.apps)

  name                               = var.apps[count.index].name
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.stub.family
  desired_count                      = 2
  deployment_maximum_percent         = 250
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds  = 30
  launch_type                        = var.run_on_fargate ? "FARGATE" : "EC2"

  network_configuration {
    security_groups  = [aws_security_group.tasks.id]
    subnets          = var.vpc_private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this[count.index].id
    container_name   = "main"
    container_port   = var.apps[count.index].http.port
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_service" "this-canary" {
  count = length(var.apps)

  name                               = "${var.apps[count.index].name}-canary"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.stub.family
  desired_count                      = 2
  deployment_maximum_percent         = 250
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds  = 30
  launch_type                        = var.run_on_fargate ? "FARGATE" : "EC2"

  network_configuration {
    security_groups  = [aws_security_group.tasks.id]
    subnets          = var.vpc_private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this-canary[count.index].id
    container_name   = "main"
    container_port   = var.apps[count.index].http.port
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
