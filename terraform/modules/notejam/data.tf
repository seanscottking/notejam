data "aws_region" "main" {}

data "template_file" "container-definitions" {
  template = "${file("${path.module}/templates/container-definitions.json.tpl")}"

  vars {
    aws_cloudwatch_log_group_id = "${aws_cloudwatch_log_group.main.id}"
    aws_region                  = "${data.aws_region.main.name}"
    image                       = "748787408638.dkr.ecr.us-east-1.amazonaws.com/notejam:latest"
    mysql_database              = "${module.rds.this_db_instance_name}"
    mysql_host                  = "${module.rds.this_db_instance_address}"
    mysql_password              = "${random_string.main.result}"
    mysql_user                  = "myusername"
    name                        = "${local.name_tag}"
  }
}

data "template_file" "container-overrides-migrate" {
  template = "${file("${path.module}/templates/container-overrides-migrate.sh.tpl")}"

  vars {
    subnet_id         = "${element(module.vpc.private_subnet_ids["private"],0)}"
    security_group_id = "${module.vpc.default_security_group_id}"
    task_definition   = "${local.name_tag}"
  }
}
