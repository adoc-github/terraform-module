output "UI_ALB_Hostname" {
  value = "http://${aws_alb.public_alb.dns_name}"
}