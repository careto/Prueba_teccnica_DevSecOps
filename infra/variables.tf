variable "aws_region" {
  description = "Región de AWS donde se implementarán los recursos."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  default = "demo-app"
}

variable "container_image" {
  default = "nginx:latest"
}

variable "container_port" {
  default = 80
}
