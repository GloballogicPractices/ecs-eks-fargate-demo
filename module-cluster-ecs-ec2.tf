module "cluster-ecs-ec2" {
  source = "./modules/cluster-ecs"

  name = "${var.name}-ecs-ec2"

  run_on_fargate = false

  aws_profile = var.aws_profile
  aws_region  = var.aws_region

  vpc_id              = module.vpc.vpc_id
  vpc_private_subnets = module.vpc.private_subnets
  vpc_public_subnets  = module.vpc.public_subnets

  ansible_run       = var.ansible_run
  ansible_trigger   = var.ansible_trigger
  ansible_arguments = var.ansible_arguments

  artifacts_dir = "${path.root}/.artifacts"

  docker_repo = aws_ecr_repository.apps.repository_url

  apps = local.apps_ecs_ec2

  tags = local.tags
}
