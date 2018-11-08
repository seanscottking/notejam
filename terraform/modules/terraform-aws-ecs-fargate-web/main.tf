locals {
  aws_elb_account_id = {
    ap-northeast-1 = "582318560864"
    ap-northeast-2 = "600734575887"
    ap-south-1     = "718504428378"
    ap-southeast-1 = "114774131450"
    ap-southeast-2 = "783225319266"
    cn-north-1     = "638102146993"
    eu-central-1   = "054676820928"
    eu-west-1      = "156460612806"
    sa-east-1      = "507241528517"
    us-east-1      = "127311923021"
    us-gov-west-1  = "048591011584"
    us-west-1      = "027434742980"
    us-west-2      = "797873946194"
  }
}

resource "aws_iam_role" "ecs-tasks" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs-execution" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = "${aws_iam_role.ecs-execution.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "main" {
  container_definitions    = "${var.container_definitions}"
  cpu                      = "${var.cpu}"
  execution_role_arn       = "${aws_iam_role.ecs-execution.arn}"
  family                   = "${var.name}"
  memory                   = "${var.memory}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = "${aws_iam_role.ecs-tasks.arn}"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name}"
}

resource "aws_ecs_service" "main" {
  depends_on = ["aws_iam_role.ecs-tasks", "aws_lb.main"]

  name        = "${var.name}"
  launch_type = "FARGATE"

  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.main.arn}"
  desired_count   = "${var.desired_count}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.main.arn}"
    container_name   = "${var.name}"
    container_port   = "${var.container_http_port}"
  }

  network_configuration = {
    subnets         = ["${var.private_subnet_ids}"]
    security_groups = ["${var.security_group_ids}"]
  }

  lifecycle = {
    ignore_changes = ["aws_ecs_task_definition.main"]
  }
}

resource "aws_lb_target_group" "main" {
  port        = "${var.container_http_port}"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_s3_bucket" "main" {
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_lb" "main" {
  subnets         = ["${var.public_subnet_ids}"]
  security_groups = ["${var.security_group_ids}", "${aws_security_group.public.id}"]

  access_logs {
    bucket  = "${aws_s3_bucket.main.bucket}"
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = "${aws_s3_bucket.main.id}"

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.main.arn}/*",
      "Principal": {
        "AWS": [
          "${local.aws_elb_account_id["${data.aws_region.main.name}"]}"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "${var.container_http_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.arn}"
    type             = "forward"
  }
}

resource "aws_security_group" "public" {
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = "${var.container_http_port}"
    to_port     = "${var.container_http_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.container_https_port}"
    to_port     = "${var.container_https_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
