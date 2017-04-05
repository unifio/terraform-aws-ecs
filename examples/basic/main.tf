# AWS Elastic Container Service (ECS) Stack

## Configures AWS provider
provider "aws" {
  region = "${var.region}"
}

## Configures base VPC
module "vpc_base" {
  source = "github.com/unifio/terraform-aws-vpc?ref=0.3.0//base"

  stack_item_fullname = "${var.stack_item_fullname}"
  stack_item_label    = "${var.stack_item_label}"
  vpc_cidr            = "172.16.0.0/24"
}

## Configures VPC availabilty zones
module "vpc_az" {
  source = "github.com/unifio/terraform-aws-vpc?ref=0.3.0//az"

  azs_provisioned     = 2
  rt_dmz_id           = "${module.vpc_base.rt_dmz_id}"
  stack_item_fullname = "${var.stack_item_fullname}"
  stack_item_label    = "${var.stack_item_label}"
  vpc_id              = "${module.vpc_base.vpc_id}"
}
