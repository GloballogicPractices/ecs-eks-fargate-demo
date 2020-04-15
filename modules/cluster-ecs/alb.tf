resource "aws_lb" "this" {
  count = length(var.apps)

  name = "${var.name}-${var.apps[count.index].name}"

  subnets         = var.vpc_public_subnets
  security_groups = [aws_security_group.alb.id]

  internal = false

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  count = length(var.apps)

  load_balancer_arn = aws_lb.this[count.index].id
  port              = var.apps[count.index].http.port
  protocol          = var.apps[count.index].http.scheme

  default_action {
    target_group_arn = aws_lb_target_group.this[count.index].id
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "http-canary" {
  count = length(var.apps)

  listener_arn = aws_lb_listener.http[count.index].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this-canary[count.index].arn
  }

  condition {
    http_header {
      http_header_name = "canary"
      values           = ["true"]
    }
  }
}


resource "aws_lb_target_group" "this" {
  count = length(var.apps)

  port        = var.apps[count.index].http.port
  protocol    = var.apps[count.index].http.scheme
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = var.apps[count.index].http.ping
    matcher             = "200"
    protocol            = var.apps[count.index].http.scheme
    interval            = 15
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 60
    enabled         = false
  }

  tags = var.tags
}

resource "aws_lb_target_group" "this-canary" {
  count = length(var.apps)

  port        = var.apps[count.index].http.port
  protocol    = var.apps[count.index].http.scheme
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = var.apps[count.index].http.ping
    matcher             = "200"
    protocol            = var.apps[count.index].http.scheme
    interval            = 15
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 60
    enabled         = false
  }

  tags = var.tags
}
