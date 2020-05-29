# Input Variables

## Resource tags
variable "stack_item_fullname" {
  type = string
}

variable "stack_item_label" {
  type = string
}

## ECS parameters
variable "cluster_id" {
  type        = string
  description = "ECS cluster ID."
}

variable "cluster_name" {
  type        = string
  description = "ECS cluster name."
}

variable "cluster_sg_id" {
  type        = string
  description = "ECS cluster security group ID."
}

variable "iam_path" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "ID of the target VPC."
}

## Service discovery parameters
variable "agent_config_override" {
  type = string
}

variable "agent_desired_count" {
  type = string
}

variable "agent_task_arn_override" {
  type = string
}

variable "consul_dc" {
  type = string
}

variable "consul_docker_image" {
  type = string
}

variable "registrator_config_override" {
  type = string
}

variable "registrator_desired_count" {
  type = string
}

variable "registrator_docker_image" {
  type = string
}

variable "registrator_task_arn_override" {
  type = string
}

variable "server_config_override" {
  type = string
}

variable "server_desired_count" {
  type = string
}

variable "server_task_arn_override" {
  type = string
}

variable "service_discovery_enabled" {
  type = string
}

variable "service_registration_enabled" {
  type = string
}

