# Input Variables

## Resource tags
variable "cluster_name" {
  description = "Name of the ECS based application stack"
  type        = "string"
}

variable "stack_item_fullname" {
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
  type        = "string"
}

variable "stack_item_label" {
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
  type        = "string"
}

## VPC parameters
variable "region" {
  default     = "us-east-1"
  description = "AWS region to be utilized."
  type        = "string"
}

variable "subnets" {
  description = "List of VPC subnets to associate with the auto scaling group."
  type        = "string"
}

variable "vpc_id" {
  description = "ID of the target VPC."
  type        = "string"
}

## Cluster parameters
variable "agent_role_name" {
  description = "Name of the IAM role to be associated with the cluster members."
  type        = "string"
}

variable "ami" {
  description = "Amazon Machine Image (AMI) of the cluster host."
  type        = "string"
}

variable "domain" {
  default     = ""
  description = "The suffix domain name"
  type        = "string"
}

variable "ecs_config" {
  default     = ""
  description = "ECS agent configuration."
  type        = "string"
}

variable "hc_check_type" {
  default     = "EC2"
  description = "Type of health check performed by the cluster. Valid values are 'ELB' or 'EC2'."
  type        = "string"
}

variable "hc_grace_period" {
  default     = "420"
  description = "Time allowed after an instance comes into service before checking health."
  type        = "string"
}

variable "instance_type" {
  default     = "t2.small"
  description = "EC2 instance type to associate with the cluster members."
  type        = "string"
}

variable "key_name" {
  type        = "string"
  description = "SSH key pair to associate with the cluster members."
}

variable "max_size" {
  default     = "3"
  description = "Maximum number of instances allowed by the cluster."
  type        = "string"
}

variable "min_size" {
  default     = "3"
  description = "Minimum number of instances allowed by the cluster."
  type        = "string"
}

variable "user_data" {
  default     = ""
  description = "Instance initialization data to associate with the cluster members."
  type        = "string"
}
