resource "aws_iam_role" "haitham_kube_iam"{
    name = "haitham_kube_iam"
    assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
    role = aws_iam_role.haitham_kube_iam.name
    policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"

}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.haitham_kube_iam.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_access" {
  role       = aws_iam_role.haitham_kube_iam.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}
resource "aws_iam_role_policy_attachment" "db_access" {
  role       = aws_iam_role.haitham_kube_iam.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

#profile
resource "aws_iam_instance_profile" "haitham_ec2_profile" {
  name = "haitham-instance-profile"
  role = aws_iam_role.haitham_kube_iam.name
}


