# Elastic Container Service (ECS) cluster

data "aws_region" "current" {
}

## Creates cloud-config data for agent cluster
data "template_file" "user_data" {
  template = var.user_data_override != "" ? "" : file("${path.module}/templates/user_data.hcl")

  vars = {
    cluster_label    = var.cluster_label
    stack_item_label = var.stack_item_label
  }
}

## Creates autoscaling cluster
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "cluster" {
  source = "github.com/unifio/terraform-aws-asg?ref=upgrade-0.12//group"

  # Resource tags
  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = "${var.cluster_label}-${var.stack_item_label}"

  # VPC parameters
  subnets = var.subnets
  vpc_id  = var.vpc_id

  # LC parameters
  ami                           = coalesce(var.ami_override, data.aws_ami.ecs_ami.id)
  associate_public_ip_address   = var.associate_public_ip_address
  ebs_optimized                 = var.ebs_optimized
  ebs_vol_del_on_term           = var.ebs_vol_del_on_term
  ebs_vol_device_name           = var.ebs_vol_device_name
  ebs_vol_encrypted             = var.ebs_vol_encrypted
  ebs_vol_iops                  = var.ebs_vol_iops
  ebs_vol_size                  = var.ebs_vol_size
  ebs_vol_snapshot_id           = var.ebs_vol_snapshot_id
  ebs_vol_type                  = var.ebs_vol_type
  enable_monitoring             = var.enable_monitoring
  instance_based_naming_enabled = var.instance_based_naming_enabled
  instance_name_prefix          = var.instance_name_prefix
  instance_profile              = aws_iam_instance_profile.agent_profile.id
  instance_tags                 = var.instance_tags
  instance_type                 = var.instance_type
  key_name                      = var.key_name
  placement_tenancy             = var.placement_tenancy
  root_vol_del_on_term          = var.root_vol_del_on_term
  root_vol_iops                 = var.root_vol_iops
  root_vol_size                 = var.root_vol_size
  root_vol_type                 = var.root_vol_type
  security_groups               = distinct(concat([module.consul.sg_id], compact(var.security_groups)))
  spot_price                    = var.spot_price
  user_data = coalesce(
    var.user_data_override,
    data.template_file.user_data.rendered,
  )

  # ASG parameters
  default_cooldown          = var.default_cooldown
  desired_capacity          = var.desired_capacity
  enabled_metrics           = var.enabled_metrics
  force_delete              = var.force_delete
  hc_check_type             = var.hc_check_type
  hc_grace_period           = var.hc_grace_period
  max_size                  = var.max_size
  min_size                  = var.min_size
  placement_group           = var.placement_group
  protect_from_scale_in     = var.protect_from_scale_in
  suspended_processes       = var.suspended_processes
  target_group_arns         = var.target_group_arns
  termination_policies      = var.termination_policies
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
}

## Updates security groups
resource "aws_security_group_rule" "agent_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = -1
  security_group_id = module.cluster.sg_id
  to_port           = 0
  type              = "egress"
}

## Registers ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.cluster_label}-${var.stack_item_label}"
}

## Enables Consul service discovery
module "consul" {
  source = "../consul"

  # Resource tags
  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = "${var.cluster_label}-${var.stack_item_label}"

  # ECS parameters
  cluster_id    = aws_ecs_cluster.cluster.id
  cluster_name  = aws_ecs_cluster.cluster.name
  cluster_sg_id = module.cluster.sg_id
  iam_path      = var.iam_path
  vpc_id        = var.vpc_id

  # Service discovery parameters
  ## TODO: Enable for auto scaling

  agent_config_override         = var.agent_config_override
  agent_desired_count           = length(var.desired_capacity) > 0 ? var.desired_capacity : var.min_size - var.server_desired_count >= 0 ? var.min_size - var.server_desired_count : "0"
  agent_task_arn_override       = var.agent_task_arn_override
  consul_dc                     = var.consul_dc
  consul_docker_image           = var.consul_docker_image
  registrator_config_override   = var.registrator_config_override
  registrator_desired_count     = length(var.desired_capacity) > 0 ? var.desired_capacity : var.min_size
  registrator_docker_image      = var.registrator_docker_image
  registrator_task_arn_override = var.registrator_task_arn_override
  server_config_override        = var.server_config_override
  server_desired_count          = var.server_desired_count
  server_task_arn_override      = var.server_task_arn_override
  service_discovery_enabled     = var.min_size - var.server_desired_count < 0 ? "false" : var.service_discovery_enabled
  service_registration_enabled  = var.service_registration_enabled
}

