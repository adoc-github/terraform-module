locals {
  ui_vars = {
    ARTIFACT = "${var.s3_bucket}/${var.s3_path}/promotions-manager-ui.master.tar.gz"
    API_URL  = "${aws_alb.private_alb.dns_name}"
    PORT     = 80
  }
}


resource "aws_launch_template" "ui" {
  depends_on = [
    aws_alb.private_alb
  ]
  name = "ui-template-${local.sandbox_id}"

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
    associate_public_ip_address = true
    security_groups = [aws_security_group.ui_sg.id]
  }

  

  user_data = base64encode( templatefile("${path.module}/userdata/ui.sh", local.ui_vars) )

  tags = {
    Name = "UI-template-${local.sandbox_id}"
  }
}

resource "aws_autoscaling_group" "ui_asg" {
  name                = "ui-asg-${local.sandbox_id}"
  vpc_zone_identifier = data.aws_subnet_ids.public_subnets.ids
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  target_group_arns = [aws_alb_target_group.ui_tg.arn]

  launch_template {
    id      = aws_launch_template.ui.id
    version = "$Latest"
  }

  tags = [{
    Name = "UI-ASG-${local.sandbox_id}"
  }]
}



resource "aws_security_group" "ui_sg" {
  name        = "UI-SG-${local.sandbox_id}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.public_alb_sg.id]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "UI-SG-${local.sandbox_id}"
  }
}