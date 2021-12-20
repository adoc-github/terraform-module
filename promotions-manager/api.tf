locals {
  api_vars = {
    ARTIFACT = "${var.s3_bucket}/${var.s3_path}/promotions-manager-api.master.tar.gz"
    DATABASE_HOST = "${aws_db_instance.default.endpoint}"
    RELEASE_NUMBER = "none"
    API_BUILD_NUMBER = "none"
    API_PORT = 3001
    DBUsername = "${var.username}"
    DBPassword = "${var.password}"
  }
}

resource "aws_launch_template" "api" {
  depends_on = [
    aws_db_instance.default
  ]
  name = "api-template-${local.sandbox_id}"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_s3_access_ip.name
  }

  image_id = "ami-0565af6e282977273"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.small"

  monitoring {
    enabled = false
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.api_sg.id]
  }

  

  user_data = base64encode( templatefile("${path.module}/userdata/api.sh", local.api_vars) )

  tags = {
    Name = "API-template-${local.sandbox_id}"
  }
}


resource "aws_security_group" "api_sg" {
  name        = "API-SG-${local.sandbox_id}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    security_groups = [aws_security_group.ui_sg.id]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "API-SG-${local.sandbox_id}"
  }
}

resource "aws_autoscaling_group" "api_asg" {
  name                = "api-asg-${local.sandbox_id}"
  vpc_zone_identifier = data.aws_subnet_ids.private_subnets.ids
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  target_group_arns = [aws_alb_target_group.api_tg.arn]

  launch_template {
    id      = aws_launch_template.api.id
    version = "$Latest"
  }

  tags = [{
    Name = "API-ASG-${local.sandbox_id}"
  }]
}