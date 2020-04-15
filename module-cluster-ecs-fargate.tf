module "cluster-ecs-fargate" {
  source = "./modules/cluster-ecs"

  name = "${var.name}-ecs-fargate"

  run_on_fargate = true

  aws_profile = var.aws_profile
  aws_region  = var.aws_region

  vpc_private_subnets = module.vpc.private_subnets
  vpc_public_subnets  = module.vpc.public_subnets

  ansible_run       = var.ansible_run
  ansible_trigger   = var.ansible_trigger
  ansible_arguments = var.ansible_arguments

  artifacts_dir = "${path.root}/.artifacts"

  docker_repo = aws_ecr_repository.apps.repository_url

  apps = local.apps_ecs_fargate

  tags = local.tags
}
