data "aws_ami" "amazon_linux_ecs" {
  count = !var.run_on_fargate ? 1 : 0

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "template_file" "user_data" {
  count = !var.run_on_fargate ? 1 : 0

  template = file("${path.module}/templates/user-data.sh")

  vars = {
    cluster_name = aws_ecs_cluster.this.name
  }
}
