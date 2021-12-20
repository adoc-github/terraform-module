resource "aws_iam_instance_profile" "ec2_s3_access_ip" {
  name = "ec2_s3_access_ip-${local.sandbox_id}"
  role = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_iam_role_policy" "ec2_s3_access_pol" {
  name = "ec2_s3_access_pol-${local.sandbox_id}"
  role = aws_iam_role.ec2_s3_access_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:R*",
          "s3:L*",
          "s3:G*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role-${local.sandbox_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_s3_access_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}