[
  {
    "name": "${name}",
    "image": "${image}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 8000
      }
    ],
    "logConfiguration": { 
       "logDriver": "awslogs",
       "options": { 
          "awslogs-group" : "${aws_cloudwatch_log_group_id}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
       }
    },
    "environment" : [
        { "name" : "MYSQL_HOST", "value" : "${mysql_host}" },
        { "name" : "MYSQL_USER", "value" : "${mysql_user}" },
        { "name" : "MYSQL_PASSWORD",  "value" : "${mysql_password}" },
        { "name" : "MYSQL_DATABASE",  "value" : "${mysql_database}" }
    ]
  }
]