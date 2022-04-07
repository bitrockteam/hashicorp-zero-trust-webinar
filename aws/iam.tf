
resource "aws_iam_user" "boundary" {
  name = "boundary"
  path = "/"
}

resource "aws_iam_access_key" "boundary" {
  user = aws_iam_user.boundary.name
}

resource "aws_iam_user_policy" "BoundaryDescribeInstances" {
  name   = "BoundaryDescribeInstances"
  user   = aws_iam_user.boundary.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
