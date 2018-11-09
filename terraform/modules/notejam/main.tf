locals {
  project     = "${basename(path.cwd)}"
  environment = "${basename(dirname(path.cwd))}"
  name_tag    = "${local.project}-${local.environment}"
}

module "vpc" {
  source = "github.com/seanscottking/terraform-aws-vpc.git"
}

resource "random_string" "main" {
  length  = 16
  special = false
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "1.15.0"

  allocated_storage       = "5"
  backup_retention_period = "0"
  backup_window           = ""
  engine                  = "mysql"
  engine_version          = "5.7"
  family                  = "mysql5.7"
  identifier              = "${local.name_tag}"
  instance_class          = "db.t2.micro"
  maintenance_window      = ""
  multi_az                = false
  name                    = "mydatabase"
  password                = "${coalesce(random_string.main.result, "")}"
  port                    = "3306"
  subnet_ids              = "${module.vpc.private_subnet_ids["private"]}"
  username                = "myusername"
  vpc_security_group_ids  = ["${module.vpc.default_security_group_id}"]
}

resource "aws_cloudwatch_log_group" "main" {}

module "mywebservice" {
  source = "../terraform-aws-ecs-fargate-web"

  container_definitions = "${data.template_file.container-definitions.rendered}"
  private_subnet_ids    = "${module.vpc.private_subnet_ids["private"]}"
  name                  = "${local.name_tag}"
  public_subnet_ids     = "${module.vpc.public_subnet_ids["public"]}"
  security_group_ids    = ["${module.vpc.default_security_group_id}"]
  vpc_id                = "${module.vpc.vpc_id}"
  container_http_port   = 8000
}

module "cicd" {
  source = "../cicd"

  name          = "${local.name_tag}"
  project       = "${local.project}"
  environment   = "${local.environment}"
  github_owner  = "${var.github_owner}"
  github_repo   = "${var.github_repo}"
  github_branch = "${var.github_branch}"
}

resource "local_file" "task-definition-migrate" {
  content  = "${data.template_file.container-overrides-migrate.rendered}"
  filename = "${path.cwd}/migrations.sh"
}
