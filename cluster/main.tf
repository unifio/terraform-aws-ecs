# Elastic Container Service (ECS) cluster

## Creates instance profile for agent instances
resource "aws_iam_instance_profile" "profile" {
  name  = "${var.cluster_name}-${var.stack_item_label}"
  roles = ["${var.agent_role_name}"]
}

## Creates cloud-init data for agent cluster
data "template_file" "ecs_config" {
  count    = "${signum(length(var.ecs_config)) + 1 % 2}"
  template = "${file("${path.module}/templates/ecs_config.tpl")}"

  vars {
    cluster_name     = "${var.cluster_name}"
    stack_item_label = "${var.stack_item_label}"
  }
}

data "template_file" "init" {
  count    = "${signum(length(var.user_data)) + 1 % 2}"
  template = "${file("${path.module}/templates/user_data.tpl")}"

  vars {
    cluster_name     = "${var.cluster_name}"
    domain           = "${var.domain}"
    ecs_config       = "${coalesce(var.ecs_config,data.template_file.ecs_config.rendered)}"
    region           = "${var.region}"
    stack_item_label = "${var.stack_item_label}"
  }
}

## Creates autoscaling cluster
module "cluster" {
  source = "github.com/unifio/terraform-aws-asg?ref=v0.2.0//group"

  # Resource tags
  stack_item_fullname = "${var.stack_item_fullname}"
  stack_item_label    = "${var.cluster_name}-${var.stack_item_label}"

  # VPC parameters
  region  = "${var.region}"
  subnets = "${var.subnets}"
  vpc_id  = "${var.vpc_id}"

  # LC parameters
  ami              = "${var.ami}"
  instance_profile = "${aws_iam_instance_profile.profile.id}"
  instance_type    = "${var.instance_type}"
  key_name         = "${var.key_name}"
  user_data        = "${coalesce(var.user_data,data.template_file.init.rendered)}"

  # ASG parameters
  hc_check_type   = "${var.hc_check_type}"
  hc_grace_period = "${var.hc_grace_period}"
  max_size        = "${var.max_size}"
  min_size        = "${var.min_size}"
}

## Updates security groups
resource "aws_security_group_rule" "sg_agent_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = -1
  security_group_id = "${module.cluster.sg_id}"
  to_port           = 0
  type              = "egress"
}

## Creates ECS application
resource "aws_ecs_cluster" "application" {
  name = "${var.cluster_name}-${var.stack_item_label}"
}
