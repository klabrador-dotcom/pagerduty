variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_port" {
  type    = number
  default = 5432
}
