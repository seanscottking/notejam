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

resource "local_file" "task-definition-migrate" {
  content  = "${data.template_file.container-overrides-migrate.rendered}"
  filename = "${path.cwd}/migrations.sh"
}

#module "codepipeline_ecs" {
#  source = "github.com/rms1000watt/terraform-aws-codepipeline-ecs.git"
#
#  github_org         = "seanscottking"
#  github_repo        = "notejam"
#  github_oauth_token = "f4c57885286e35ec0cfd50bd9613b285dcce33e6"
#
#  ecs_cluster         = "notejam-dev"
#  ecs_service         = "notejam-dev"
#  ecs_task_definition = "notejam-dev"
#}

