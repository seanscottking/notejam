aws ecs run-task \
--launch-type FARGATE \
--cluster notejam-dev \
--task-definition notejam-dev \
--network-configuration '{ "awsvpcConfiguration": { "subnets": ["subnet-0d05170d6a7f01f5e"],"securityGroups": ["sg-0a0924f579ac4b0de"],"assignPublicIp": "DISABLED" }}' \
--overrides '{ "containerOverrides": [{ "name": "notejam-dev", "command": ["php","artisan","migrate","--force"] } ]}'
