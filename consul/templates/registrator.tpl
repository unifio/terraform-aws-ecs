[{
  "name": "registrator",
  "image": "${docker_image}",
  "memory": 16,
  "cpu": 10,
  "essential": true,
  "mountPoints": [{
    "containerPath": "/tmp/docker.sock",
    "sourceVolume": "docker_socket",
    "readOnly": true
  }],
  "command": [
    "-resync",
    "60",
    "-retry-attempts",
    "10",
    "-retry-interval",
    "1000",
    "-ip",
    "127.0.0.1",
    "consul://localhost:8500"
  ]
}]
