######### Public ALB for UI ##############

resource "aws_security_group" "public_alb_sg" {
  name        = "Public-ALB-SG-${local.sandbox_id}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public-ALB-SG-${local.sandbox_id}"
  }
}

resource "aws_alb" "public_alb" {
  name            = "UI-ALB-${local.sandbox_id}"
  security_groups = ["${aws_security_group.public_alb_sg.id}"]
  subnets         = data.aws_subnet_ids.public_subnets.ids
  tags = {
    Name = "UI-ALB-${local.sandbox_id}"
  }
}

resource "aws_alb_target_group" "ui_tg" {
  name     = "UI-TG-${local.sandbox_id}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_alb_listener" "ui_listener" {
  load_balancer_arn = "${aws_alb.public_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ui_tg.arn}"
    type             = "forward"
  }
}


######### Private ALB for API ##############

resource "aws_security_group" "private_alb_sg" {
  name        = "Private-ALB-SG-${local.sandbox_id}"
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
    Name = "Private-ALB-SG-${local.sandbox_id}"
  }
}

resource "aws_alb" "private_alb" {
  name            = "API-ALB-${local.sandbox_id}"
  security_groups = ["${aws_security_group.private_alb_sg.id}"]
  subnets         = data.aws_subnet_ids.private_subnets.ids
  tags = {
    Name = "API-ALB-${local.sandbox_id}"
  }
}

resource "aws_alb_target_group" "api_tg" {
  name     = "API-TG-${local.sandbox_id}"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/"
    port = 3001
  }
}

resource "aws_alb_listener" "api_listener" {
  load_balancer_arn = "${aws_alb.private_alb.arn}"
  port              = "3001"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.api_tg.arn}"
    type             = "forward"
  }
}