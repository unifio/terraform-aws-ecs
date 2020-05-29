# AWS Elastic Container Service (ECS) Stack Prerequisites

## Configures AWS provider
provider "aws" {
  region = var.region
}

## Configures base VPC
module "vpc_base" {
  source = "github.com/unifio/terraform-aws-vpc?ref=upgrade-0.12//base"

  enable_dns          = "true"
  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = var.stack_item_label
  vpc_cidr            = "172.16.0.0/24"
}

## Configures VPC availabilty zones
module "vpc_az" {
  source = "github.com/unifio/terraform-aws-vpc?ref=upgrade-0.12//az"

  azs_provisioned     = 2
  lans_per_az         = 0
  rt_dmz_id           = module.vpc_base.rt_dmz_id
  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = var.stack_item_label
  vpc_id              = module.vpc_base.vpc_id
}

## Configures routing
resource "aws_route" "dmz-to-igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc_base.igw_id
  route_table_id         = module.vpc_base.rt_dmz_id
}
