# Consul service discovery & configuration

data "aws_region" "current" {
}

locals {
  service_discovery_check = var.service_discovery_enabled == "true" ? 1 : 0
  consul_server_check     = var.server_desired_count > 0 ? 1 : 0
  consul_agent_check      = var.agent_desired_count > 0 ? 1 : 0
  registrator_check       = var.service_registration_enabled == "true" ? 1 : 0
}

## Creates Consul communication security group

resource "aws_security_group" "consul_sg" {
  count = local.service_discovery_check * local.consul_server_check

  description = "${var.stack_item_fullname} Consul security group"
  name_prefix = "consul-${var.stack_item_label}-"
  vpc_id      = var.vpc_id

  tags = {
    application = var.stack_item_fullname
    managed_by  = "terraform"
    Name        = "consul-${var.stack_item_label}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

### Traffic within the environment
resource "aws_security_group_rule" "agent_consul_rpc" {
  count = local.service_discovery_check * local.consul_server_check

  from_port         = 8300
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg[0].id
  self              = true
  to_port           = 8300
  type              = "ingress"
}

resource "aws_security_group_rule" "agent_serf_lan_tcp" {
  count = local.service_discovery_check * local.consul_server_check

  from_port         = 8301
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg[0].id
  self              = true
  to_port           = 8301
  type              = "ingress"
}

resource "aws_security_group_rule" "agent_serf_lan_udp" {
  count = local.service_discovery_check * local.consul_server_check

  from_port         = 8301
  protocol          = "udp"
  security_group_id = aws_security_group.consul_sg[0].id
  self              = true
  to_port           = 8301
  type              = "ingress"
}

resource "aws_security_group_rule" "agent_serf_wan_tcp" {
  count = local.service_discovery_check * local.consul_server_check

  from_port         = 8302
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg[0].id
  self              = true
  to_port           = 8302
  type              = "ingress"
}

resource "aws_security_group_rule" "agent_serf_wan_udp" {
  count = local.service_discovery_check * local.consul_server_check

  from_port         = 8302
  protocol          = "udp"
  security_group_id = aws_security_group.consul_sg[0].id
  self              = true
  to_port           = 8302
  type              = "ingress"
}

resource "aws_security_group_rule" "agent_http" {
  count = local.service_discovery_check * local.consul_server_check

  from_port         = 8500
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg[0].id
  self              = true
  to_port           = 8500
  type              = "ingress"
}

## Creates ALB target group
resource "aws_alb_target_group" "consul_group" {
  count = local.service_discovery_check * local.consul_server_check

  name     = "consul-${var.stack_item_label}"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/v1/agent/self"
    port     = 8500
    protocol = "HTTP"
  }

  tags = {
    application = var.stack_item_fullname
    Name        = "consul-${var.stack_item_label}"
    managed_by  = "terraform"
  }
}

## Creates ECS tasks

### Consul server
data "template_file" "server_config" {
  count = local.service_discovery_check * local.consul_server_check

  template = file("${path.module}/templates/server.hcl")

  vars = {
    bootstrap_expect = var.server_desired_count
    consul_dc        = var.consul_dc
    docker_image     = var.consul_docker_image
    join             = var.cluster_name
  }
}

resource "aws_ecs_task_definition" "server_task" {
  count = local.service_discovery_check * local.consul_server_check

  container_definitions = coalesce(
    var.server_config_override,
    data.template_file.server_config[0].rendered,
  )
  family        = "consul-server-${var.stack_item_label}"
  network_mode  = "host"
  task_role_arn = aws_iam_role.consul_role[0].arn

  volume {
    host_path = "/etc/consul.d"
    name      = "consul_config"
  }

  volume {
    host_path = "/var/lib/consul"
    name      = "consul_data"
  }
}

### Consul agent
data "template_file" "agent_config" {
  count = local.service_discovery_check * local.consul_agent_check

  template = file("${path.module}/templates/agent.hcl")

  vars = {
    consul_dc    = var.consul_dc
    docker_image = var.consul_docker_image
    join         = var.cluster_name
  }
}

resource "aws_ecs_task_definition" "agent_task" {
  count = local.service_discovery_check * local.consul_agent_check

  container_definitions = coalesce(
    var.agent_config_override,
    data.template_file.agent_config[0].rendered,
  )
  family        = "consul-agent-${var.stack_item_label}"
  network_mode  = "host"
  task_role_arn = aws_iam_role.consul_role[0].arn

  volume {
    host_path = "/etc/consul.d"
    name      = "consul_config"
  }

  volume {
    host_path = "/var/lib/consul"
    name      = "consul_data"
  }
}

### Registrator
data "template_file" "registrator_config" {
  count = local.service_discovery_check * local.registrator_check

  template = file("${path.module}/templates/registrator.hcl")

  vars = {
    docker_image = var.registrator_docker_image
  }
}

resource "aws_ecs_task_definition" "registrator_task" {
  count = local.service_discovery_check * local.registrator_check

  container_definitions = coalesce(
    var.registrator_config_override,
    data.template_file.registrator_config[0].rendered,
  )
  family       = "registrator-${var.stack_item_label}"
  network_mode = "host"

  volume {
    host_path = "/var/run/docker.sock"
    name      = "docker_socket"
  }
}

## Creates ECS services

### Consul server
resource "aws_ecs_service" "consul_server" {
  count      = local.service_discovery_check * local.consul_server_check
  depends_on = [aws_iam_role.ecs_role]

  cluster                            = var.cluster_id
  deployment_maximum_percent         = "100"
  deployment_minimum_healthy_percent = "50"
  desired_count                      = var.server_desired_count
  iam_role                           = aws_iam_role.ecs_role[0].arn
  name                               = "consul-server"
  task_definition = coalesce(
    var.server_task_arn_override,
    aws_ecs_task_definition.server_task[0].arn,
  )

  load_balancer {
    container_name   = "consul-server"
    container_port   = "8500"
    target_group_arn = aws_alb_target_group.consul_group[0].arn
  }

  placement_constraints {
    type = "distinctInstance"
  }
}

### Consul agent
resource "aws_ecs_service" "consul_agent" {
  count = local.service_discovery_check * local.consul_agent_check

  cluster                            = var.cluster_id
  deployment_maximum_percent         = "100"
  deployment_minimum_healthy_percent = "50"
  desired_count                      = var.agent_desired_count
  name                               = "consul-agent"
  task_definition = coalesce(
    var.agent_task_arn_override,
    aws_ecs_task_definition.agent_task[0].arn,
  )

  placement_constraints {
    type = "distinctInstance"
  }
}

### Registrator
resource "aws_ecs_service" "registrator" {
  count = local.service_discovery_check * local.registrator_check

  cluster                            = var.cluster_id
  deployment_maximum_percent         = "100"
  deployment_minimum_healthy_percent = "50"
  desired_count                      = var.registrator_desired_count
  name                               = "registrator"
  task_definition = coalesce(
    var.registrator_task_arn_override,
    aws_ecs_task_definition.registrator_task[0].arn,
  )

  placement_constraints {
    type = "distinctInstance"
  }
}

