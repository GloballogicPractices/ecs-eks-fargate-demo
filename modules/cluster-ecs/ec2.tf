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
  create_lc = !var.run_on_fargate

  image_id             = var.run_on_fargate ? "" : data.aws_ami.amazon_linux_ecs[0].id
  instance_type        = "t3.medium"
//  security_groups      = [module.vpc.default_security_group_id]
  iam_instance_profile = var.run_on_fargate ? "" : aws_iam_instance_profile.this[0].id
  user_data            = var.run_on_fargate ? "" : data.template_file.user_data[0].rendered

  # Auto scaling group
  asg_name                  = var.name
  vpc_zone_identifier       = var.vpc_private_subnets
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags_as_map = var.tags
}
