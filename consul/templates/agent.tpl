[{
  "name": "consul-agent",
  "image": "${docker_image}",
  "memory": 16,
  "cpu": 10,
  "essential": true,
  "portMappings": [{
    "hostPort": 8500,
    "containerPort": 8500,
    "protocol": "tcp"
  }],
  "mountPoints": [{
    "containerPath": "/consul/config",
    "sourceVolume": "consul_config",
    "readOnly": false
  },
  {
    "containerPath": "/consul/data",
    "sourceVolume": "consul_data",
    "readOnly": false
  }],
  "command": [
    "agent",
    "-raft-protocol=3",
    "-dc=${consul_dc}",
    "-retry-join-ec2-tag-key=aws:autoscaling:groupName",
    "-retry-join-ec2-tag-value=${join}"
  ],
  "environment": [{
    "name": "CONSUL_BIND_INTERFACE",
    "value": "eth0"
  },
  {
    "name": "CONSUL_CLIENT_INTERFACE",
    "value": "eth0"
  },
  {
    "name": "SERVICE_8500_IGNORE",
    "value": "true"
  }]
}]
