############################################
# VPC
############################################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

############################################
# INTERNET GATEWAY
############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

############################################
# PUBLIC SUBNETS
############################################

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-b"
  }
}

############################################
# ROUTE TABLE
############################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

############################################
# SECURITY GROUP - ALB
############################################

resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# SECURITY GROUP - ECS
############################################

resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-ecs-sg"
  description = "ECS Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Traffic from ALB"

    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"

    security_groups = [
      aws_security_group.alb_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# ECR REPOSITORY
############################################

resource "aws_ecr_repository" "app" {
  name = var.app_name

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}

############################################
# ECS CLUSTER
############################################

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

############################################
# APPLICATION LOAD BALANCER
############################################

resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"

  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

############################################
# TARGET GROUP
############################################

resource "aws_lb_target_group" "app" {
  name = "${var.app_name}-tg"

  port     = var.container_port
  protocol = "HTTP"

  target_type = "ip"

  vpc_id = aws_vpc.main.id

  health_check {
    path = "/"

    matcher = "200"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

############################################
# LISTENER
############################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.app.arn
  }
}

############################################
# ECS SERVICE
############################################
# IMPORTANTE:
# No se crea Task Definition.
# El service queda listo para que
# luego despliegues tu task.
############################################

resource "aws_ecs_service" "app" {
  name    = "${var.app_name}-service"
  cluster = aws_ecs_cluster.main.id

  desired_count = 0

  launch_type = "FARGATE"

  scheduling_strategy = "REPLICA"

  network_configuration {
    subnets = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]

    security_groups = [
      aws_security_group.ecs_sg.id
    ]

    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }

  depends_on = [
    aws_lb_listener.http
  ]
}