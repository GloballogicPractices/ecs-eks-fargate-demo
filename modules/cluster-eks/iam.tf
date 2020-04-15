resource "aws_iam_role" "fargate" {
  count = var.run_on_fargate ? 1 : 0

  name = var.name

  tags = var.tags

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
  count = var.run_on_fargate ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate[0].name
}

// TODO: Use this user for ansible
// And don't use it for ALB ingress
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
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
