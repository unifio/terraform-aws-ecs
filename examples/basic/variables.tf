# Input variables

## Resource tags
variable "cluster_label" {
  type = string
}

variable "stack_item_fullname" {
  type = string
}

variable "stack_item_label" {
  type = string
}

## Cluster parameters
variable "instance_type" {
  type = string
}

variable "max_size" {
  type = string
}

variable "min_size" {
  type = string
}

variable "region" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
