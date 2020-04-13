resource "aws_ecs_cluster" "this" {
  name = var.name

  tags = var.tags
}

resource "aws_ecs_task_definition" "stub" {
  container_definitions = file("${path.module}/templates/td.json")

  family = "${var.name}-stub"
}

//resource "aws_ecs_service" "this" {
//  count = length(var.apps)
//
//  name                               = var.apps[count.index].name
//  cluster                            = aws_ecs_cluster.this.id
//  task_definition                    = aws_ecs_task_definition.stub[0].task_definition
//  desired_count                      = 2
//  deployment_maximum_percent         = 250
//  deployment_minimum_healthy_percent = 50
//  health_check_grace_period_seconds  = 30
//  launch_type                        = "FARGATE"
//
//  network_configuration {
//    security_groups  = [aws_security_group.tasks[0].id]
//    subnets          = var.vpc_private_subnets
//    assign_public_ip = false
//  }
//
//  load_balancer {
//    target_group_arn = aws_lb_target_group.this[0].id
//    container_name   = local.container_name
//    container_port   = 443
//  }
//
//  lifecycle {
//    ignore_changes = [task_definition]
//  }
//
//  propagate_tags = "TASK_DEFINITION"
//
//  tags = var.tags
//}
