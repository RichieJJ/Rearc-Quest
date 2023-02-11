resource "aws_ecs_cluster" "rearc-ecs-cluster" {
  name = "rearc-ecs-cluster"
}

resource "aws_cloudwatch_log_group" "rearc-task-log-group" {
  name = "rearc-task-log-group"
}

data "aws_ecr_repository" "rearc-container-repo" {
  name = "rearc-container-repo"
}

resource "aws_ecs_task_definition" "rearc-task-definition" {
  family = "rearc-task-definition"
  container_definitions = jsonencode([
    {
      "name": "rearc-container-definition",
      "image": "${data.aws_ecr_repository.rearc-container-repo.repository_url}:latest",
      "essential": true,
      "memoryReservation": 128
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ]
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.rearc-task-log-group.name}"
          "awslogs-region": "${var.aws_region}"
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ])
  execution_role_arn = aws_iam_role.rearc-ecs-task-execution-role.arn
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
}


resource "aws_ecs_service" "rearc-ecs-service" {
  name = "rearc-ecs-service"
  cluster = aws_ecs_cluster.rearc-ecs-cluster.id
  task_definition = aws_ecs_task_definition.rearc-task-definition.id
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.rearc-ecs-security-group.id]
    subnets = [aws_subnet.rearc-subnet-1.id, aws_subnet.rearc-subnet-2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.rearc-target-group.id
    container_name = "rearc-container-definition"
    container_port = "3000"
  }
}

resource "aws_appautoscaling_target" "rearc-autoscalling" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.rearc-ecs-cluster.name}/${aws_ecs_service.rearc-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn = aws_iam_role.rearc-ecs-autoscaling-role.arn
  min_capacity       = 1
  max_capacity       = 1
}
