aws ecs run-task \
--launch-type FARGATE \
--cluster notejam-dev \
--task-definition notejam-dev \
--network-configuration '{ "awsvpcConfiguration": { "subnets": ["${subnet_id}"],"securityGroups": ["${security_group_id}"],"assignPublicIp": "DISABLED" }}' \
--overrides '{ "containerOverrides": [{ "name": "${task_definition}", "command": ["php","artisan","migrate","--force"] } ]}'
