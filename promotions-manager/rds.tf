resource "aws_db_subnet_group" "rds" {
  name = "rds-${local.sandbox_id}-subnet-group"
  subnet_ids = data.aws_subnet_ids.private_subnets.ids

  tags = {
    Name = "RDS-subnet-group-${local.sandbox_id}"
  }
}


resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.medium"
  identifier           = "rds-${local.sandbox_id}"
  name                 = "${var.db_name}"
  username             = "${var.username}"
  password             = "${var.password}"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${aws_db_subnet_group.rds.id}"
  vpc_security_group_ids    = ["${aws_security_group.rds.id}"]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}

resource "aws_security_group" "rds" {
  name        = "rds-${local.sandbox_id}_sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    security_groups = [aws_security_group.api_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
