resource "aws_iam_role" "fargate" {
  name = "eks-fargate-profile-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version   = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fargate-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

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
  name               = "${var.name}-fargate_task_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_policy.json
}

resource "aws_iam_role_policy" "fargate_task_role" {
  name = "${var.name}-fargate_task_role"
  role = aws_iam_role.fargate_task_role.id

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
