terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      
    }
  }
}
data "aws_vpc" "main" {
  id = "${var.vpc_id}"
}

resource "aws_ecr_repository" "aws-ecr" {
  name = "${var.app_name}-${var.app_environment}-ecr"
 
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
}

resource "aws_security_group" "service_security_group" {
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-service-sg"
    Environment = var.app_environment
  }
}

 resource "aws_lb_target_group" "albtg" {
  name        = "albtg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_lb" "alb" {
  name               = "factorialalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = var.vpc_subnets

}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

   default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.albtg.arn
   }

  
}

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.app_name}-${var.app_environment}-cluster"
  
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.app_environment}-container",
      "image": "${aws_ecr_repository.aws-ecr.repository_url}:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        },
        {
          "containerPort": 5000,
          "hostPort": 5000
        }

      ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = "arn:aws:iam::433611892159:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::433611892159:role/ecsTaskExecutionRole"

}

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-${var.app_environment}-ecs-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = aws_ecs_task_definition.aws-ecs-task.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = var.vpc_private_subnets
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.albtg.arn
    container_name   = "${var.app_name}-${var.app_environment}-container"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.listener]
}

