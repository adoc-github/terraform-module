
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  description = "Torque sandbox vpc"
  default = "vpc-0e88b1edef0d8c529"
}

##### RDS Specific ############
variable "db_name" {
  description = "db name"
  default = "demo_db"
}

variable "username" {
  description = "User name"
  default = "root"
}

variable "password" {
  description = "Database password"
  default = "Torque!123"
}

######## Artifact Setup #############

variable "s3_bucket" {
  description = "S3 bucket used for artifact storage"
  default = "cfox-artifactbucket-quali"
}

variable "s3_path" {
  description = "S3 path used for artifact storage"
  default = "artifacts/latest"
}

