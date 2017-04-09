# Input variables

## Resource tags
variable "cluster_name" {
  type = "string"
}

variable "stack_item_fullname" {
  type = "string"
}

variable "stack_item_label" {
  type = "string"
}

## Cluster parameters
variable "ami_override" {
  type = "string"
}

variable "enable_monitoring" {
  type = "string"
}

variable "iam_path" {
  type = "string"
}

variable "instance_based_naming_enabled" {
  type = "string"
}

variable "instance_type" {
  type = "string"
}

variable "max_size" {
  type = "string"
}

variable "min_size" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "subnets" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}
