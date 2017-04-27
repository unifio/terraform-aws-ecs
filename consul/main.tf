# Consul service discovery & configuration

## Set Terraform version constraint
terraform {
  required_version = "> 0.9.0"
}

data "aws_region" "current" {
  current = true
}

## Updates cluster security group

### Traffic within the environment
resource "aws_security_group_rule" "agent_consul_rpc" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  cidr_blocks       = ["${var.consul_gossip_cidrs}"]
  from_port         = 8300
  protocol          = "tcp"
  security_group_id = "${var.cluster_sg_id}"
  to_port           = 8300
  type              = "ingress"
}

resource "aws_security_group_rule" "agent_serf_lan_tcp" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  cidr_blocks       = ["${var.consul_gossip_cidrs}"]
  from_port         = 8301
  protocol          = "tcp"
  security_group_id = "${var.cluster_sg_id}"
  to_port           = 8301
  type              = "ingress"
}

resource "aws_security_group_rule" "agent_serf_lan_udp" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  cidr_blocks       = ["${var.consul_gossip_cidrs}"]
  from_port         = 8301
  protocol          = "udp"
  security_group_id = "${var.cluster_sg_id}"
  to_port           = 8301
  type              = "ingress"
}

resource "aws_security_group_rule" "agent_serf_wan_tcp" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  cidr_blocks       = ["${var.consul_gossip_cidrs}"]
  from_port         = 8302
  protocol          = "tcp"
  security_group_id = "${var.cluster_sg_id}"
  to_port           = 8302
  type              = "ingress"
}

resource "aws_security_group_rule" "agent_serf_wan_udp" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  cidr_blocks       = ["${var.consul_gossip_cidrs}"]
  from_port         = 8302
  protocol          = "udp"
  security_group_id = "${var.cluster_sg_id}"
  to_port           = 8302
  type              = "ingress"
}

### Traffic from the load balancer
resource "aws_security_group_rule" "agent_consul_http_api" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  from_port                = 8500
  protocol                 = "tcp"
  security_group_id        = "${var.cluster_sg_id}"
  source_security_group_id = "${var.lb_sg_id}"
  to_port                  = 8500
  type                     = "ingress"
}

## Creates ALB target group
resource "aws_alb_target_group" "consul_group" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  name     = "consul-${var.stack_item_label}"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path     = "/v1/agent/self"
    port     = 8500
    protocol = "HTTP"
  }

  tags {
    application = "${var.stack_item_fullname}"
    Name        = "consul-${var.stack_item_label}"
    managed_by  = "terraform"
  }
}

resource "aws_alb_listener_rule" "consul_rule" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  listener_arn = "${var.lb_listener_arn}"
  priority     = "${var.lb_listener_rule_priority}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.consul_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}

## Creates ECS tasks

### Consul server
data "template_file" "server_config" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  template = "${file("${path.module}/templates/server.tpl")}"

  vars {
    bootstrap_expect = "${var.server_desired_count}"
    consul_dc        = "${var.consul_dc}"
    docker_image     = "${var.consul_docker_image}"
    join             = "${var.cluster_name}"
  }
}

resource "aws_ecs_task_definition" "server_task" {
  count = "${var.service_discovery_enabled == "true" ? "1" : "0"}"

  container_definitions = "${coalesce(var.server_config_override,data.template_file.server_config.rendered)}"
  family                = "consul-server-${var.stack_item_label}"
  network_mode          = "host"
  task_role_arn         = "${aws_iam_role.consul_role.arn}"

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
  count = "${var.service_discovery_enabled == "true" && var.agent_desired_count > 0 ? "1" : "0"}"

  template = "${file("${path.module}/templates/agent.tpl")}"

  vars {
    consul_dc    = "${var.consul_dc}"
    docker_image = "${var.consul_docker_image}"
    join         = "${var.cluster_name}"
  }
}

resource "aws_ecs_task_definition" "agent_task" {
  count = "${var.service_discovery_enabled == "true" && var.agent_desired_count > 0 ? "1" : "0"}"

  container_definitions = "${coalesce(var.agent_config_override,data.template_file.agent_config.rendered)}"
  family                = "consul-agent-${var.stack_item_label}"
  network_mode          = "host"
  task_role_arn         = "${aws_iam_role.consul_role.arn}"

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
  count = "${var.service_discovery_enabled == "true" && var.service_registration_enabled == "true" ? "1" : "0"}"

  template = "${file("${path.module}/templates/registrator.tpl")}"

  vars {
    docker_image = "${var.registrator_docker_image}"
  }
}

resource "aws_ecs_task_definition" "registrator_task" {
  count = "${var.service_discovery_enabled == "true" && var.service_registration_enabled == "true" ? "1" : "0"}"

  container_definitions = "${coalesce(var.registrator_config_override,data.template_file.registrator_config.rendered)}"
  family                = "registrator-${var.stack_item_label}"
  network_mode          = "host"

  volume {
    host_path = "/var/run/docker.sock"
    name      = "docker_socket"
  }
}

## Creates ECS services

### Consul server
resource "aws_ecs_service" "consul_server" {
  count      = "${var.service_discovery_enabled == "true" ? "1" : "0"}"
  depends_on = ["aws_iam_role.ecs_role", "aws_alb_listener_rule.consul_rule"]

  cluster                            = "${var.cluster_id}"
  deployment_maximum_percent         = "100"
  deployment_minimum_healthy_percent = "50"
  desired_count                      = "${var.server_desired_count}"
  iam_role                           = "${aws_iam_role.ecs_role.arn}"
  name                               = "consul-server"
  task_definition                    = "${coalesce(var.server_task_arn_override,aws_ecs_task_definition.server_task.arn)}"

  load_balancer {
    container_name   = "consul-server"
    container_port   = "8500"
    target_group_arn = "${aws_alb_target_group.consul_group.arn}"
  }

  placement_constraints {
    type = "distinctInstance"
  }
}

### Consul agent
resource "aws_ecs_service" "consul_agent" {
  count = "${var.service_discovery_enabled == "true" && var.agent_desired_count > 0 ? "1" : "0"}"

  cluster                            = "${var.cluster_id}"
  deployment_maximum_percent         = "100"
  deployment_minimum_healthy_percent = "50"
  desired_count                      = "${var.agent_desired_count}"
  name                               = "consul-agent"
  task_definition                    = "${coalesce(var.agent_task_arn_override,aws_ecs_task_definition.agent_task.arn)}"

  placement_constraints {
    type = "distinctInstance"
  }
}

### Registrator
resource "aws_ecs_service" "registrator" {
  count = "${var.service_discovery_enabled == "true" && var.service_registration_enabled == "true" ? "1" : "0"}"

  cluster                            = "${var.cluster_id}"
  deployment_maximum_percent         = "100"
  deployment_minimum_healthy_percent = "50"
  desired_count                      = "${var.registrator_desired_count}"
  name                               = "registrator"
  task_definition                    = "${coalesce(var.registrator_task_arn_override,aws_ecs_task_definition.registrator_task.arn)}"

  placement_constraints {
    type = "distinctInstance"
  }
}
