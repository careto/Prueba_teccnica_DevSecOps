variable "aws_region" {
  description = "region aws"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  default = "prueba-tecnica"
}

variable "container_port" {
  default = 80
}