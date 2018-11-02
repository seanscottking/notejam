aws ecs run-task \
--launch-type FARGATE \
--cluster notejam-dev \
--task-definition notejam-dev \
--network-configuration '{ "awsvpcConfiguration": { "subnets": ["subnet-05e27c3afaf75a5e1"],"securityGroups": ["sg-09c71464ccd9c67e2"],"assignPublicIp": "DISABLED" }}' \
--overrides '{ "containerOverrides": [{ "name": "notejam-dev", "command": ["php","artisan","migrate","--force"] } ]}'
