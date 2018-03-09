# AWS Elastic Container Service (ECS) Stack

## Configures AWS provider
provider "aws" {
  region = "${var.region}"
}

## Creates logs bucket
resource "random_id" "bucket" {
  byte_length = 8
}

resource "aws_s3_bucket" "logs" {
  bucket = "unifio-ecs-exmpl-${random_id.bucket.hex}"
  acl    = "private"
}

## Creates cloud-config
data "template_file" "init" {
  template = "${file("${path.module}/user_data.hcl")}"

  vars {
    cluster_label    = "${var.cluster_label}"
    stack_item_label = "${var.stack_item_label}"
  }
}

## Configures ECS cluster
module "cluster" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-ecs?ref=master//cluster"
  source = "../../cluster"

  # Resource tags
  cluster_label       = "${var.cluster_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
  stack_item_label    = "${var.stack_item_label}"

  # Cluster parameters
  associate_public_ip_address   = "true"
  ami_override                  = "${var.ami_override}"
  enable_monitoring             = "${var.enable_monitoring}"
  iam_path                      = "${var.iam_path}"
  instance_based_naming_enabled = "${var.instance_based_naming_enabled}"

  instance_tags = {
    "env" = "example"
  }

  instance_type       = "${var.instance_type}"
  logs_bucket_enabled = "true"
  logs_bucket_name    = "${aws_s3_bucket.logs.id}"
  max_size            = "${var.max_size}"
  min_size            = "${var.min_size}"
  subnets             = ["${var.subnets}"]
  user_data_override  = "${data.template_file.init.rendered}"
  vpc_id              = "${var.vpc_id}"

  # Service discovery parameters
  service_discovery_enabled    = "${var.service_discovery_enabled}"
  service_registration_enabled = "${var.service_registration_enabled}"
}

# Configures ALB for internal dashboards

## Creates elastic load balancer security group
resource "aws_security_group" "lb" {
  name_prefix = "${var.stack_item_label}-lb-"
  description = "${var.stack_item_fullname} load balancer security group"
  vpc_id      = "${var.vpc_id}"

  tags {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-lb"
  }
}

### Creates ELB security group rules
resource "aws_security_group_rule" "lb_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = -1
  security_group_id = "${aws_security_group.lb.id}"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "lb_http" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.lb.id}"
  to_port           = 80
  type              = "ingress"
}

resource "aws_alb" "lb" {
  name            = "${var.cluster_label}-${var.stack_item_label}"
  security_groups = ["${aws_security_group.lb.id}", "${module.cluster.consul_sg_id}"]
  subnets         = ["${var.subnets}"]

  tags {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}"
  }
}

resource "aws_alb_target_group" "default" {
  name     = "default-${var.stack_item_label}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    port     = 80
    protocol = "HTTP"
  }

  tags {
    application = "${var.stack_item_fullname}"
    Name        = "default-${var.stack_item_label}"
    managed_by  = "terraform"
  }
}

resource "aws_alb_listener" "admin" {
  load_balancer_arn = "${aws_alb.lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "consul_rule" {
  count = "${var.service_discovery_enabled == "true" ? 1 : 0}"

  listener_arn = "${aws_alb_listener.admin.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${module.cluster.consul_target_group_arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}
