# AWS Elastic Container Service (ECS) Stack

## Configures AWS provider
provider "aws" {
  region = var.region
}

## Configures ECS cluster
module "cluster" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-ecs?ref=master//cluster"
  source = "../../cluster"

  # Resource tags
  cluster_label       = var.cluster_label
  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = var.stack_item_label

  # Cluster parameters
  associate_public_ip_address = "true"
  instance_type               = var.instance_type
  max_size                    = var.max_size
  min_size                    = var.min_size
  subnets                     = var.subnets
  vpc_id                      = var.vpc_id
}
