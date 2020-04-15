data "aws_iam_policy_document" "ecs_tasks_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy" "ecsTaskExecutionRole" {
  name = var.name
  role = aws_iam_role.ecsTaskExecutionRole.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ecsPull",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "logs:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "fargate_task_role" {
  count = var.run_on_fargate ? 1 : 0

  name               = "${var.name}-fargate_task_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy" "fargate_task_role" {
  count = var.run_on_fargate ? 1 : 0

  name = "${var.name}-fargate_task_role"
  role = aws_iam_role.fargate_task_role[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ecsPull",
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:Put*",
        "s3:Delete*",
        "s3:ListBucket*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "this" {
  count = !var.run_on_fargate ? 1 : 0

  name = "${var.name}-ecs_instance_role"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  count = !var.run_on_fargate ? 1 : 0

  role       = aws_iam_role.this[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  count = !var.run_on_fargate ? 1 : 0

  role       = aws_iam_role.this[0].id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

// TODO: Use this user for ansible
resource "aws_iam_user" "ansible" {
  name = var.name
  path = "/system/"

  tags = var.tags
}

resource "aws_iam_access_key" "ansible" {
  user = aws_iam_user.ansible.name
}

resource "aws_iam_user_policy" "ansible" {
  name = var.name
  user = aws_iam_user.ansible.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
