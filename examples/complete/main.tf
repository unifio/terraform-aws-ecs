# AWS Elastic Container Service (ECS) Stack

## Configures AWS provider
provider "aws" {
  region = "${var.region}"
}

## Creates logs bucket
resource "aws_s3_bucket" "logs" {
  bucket = "unifio-ecs-exmpl-logs-bucket"
  acl    = "private"
}

## Creates cloud-config
data "template_file" "init" {
  template = "${file("${path.module}/user_data.tpl")}"

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
  subnets             = ["${split(",",var.subnets)}"]
  user_data_override  = "${data.template_file.init.rendered}"
  vpc_id              = "${var.vpc_id}"
}
