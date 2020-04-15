resource "aws_iam_instance_profile" "this" {
  count = !var.run_on_fargate ? 1 : 0

  name = "${var.name}-ecs_instance_profile"
  role = aws_iam_role.this[0].name
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = var.name

  create_asg = !var.run_on_fargate
  create_lc  = !var.run_on_fargate

  image_id             = var.run_on_fargate ? "" : data.aws_ami.amazon_linux_ecs[0].id
  instance_type        = "t3.medium"
  //  security_groups      = [module.vpc.default_security_group_id]
  iam_instance_profile = var.run_on_fargate ? "" : aws_iam_instance_profile.this[0].id
  user_data            = var.run_on_fargate ? "" : data.template_file.user_data[0].rendered

  # Auto scaling group
  asg_name                  = var.name
  vpc_zone_identifier       = var.vpc_private_subnets
  health_check_type         = "EC2"
  min_size                  = 2
  max_size                  = 5
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags_as_map = var.tags
}

resource "aws_security_group" "alb" {
  name        = "${var.name}-ecs-alb"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "tasks" {
  name        = "${var.name}-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

