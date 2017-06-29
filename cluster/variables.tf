# Input variables

## Resource tags
variable "cluster_label" {
  type        = "string"
  description = "Short form identifier for this cluster."
}

variable "stack_item_fullname" {
  type        = "string"
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
}

variable "stack_item_label" {
  type        = "string"
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
}

## VPC parameters
variable "subnets" {
  type        = "list"
  description = "A list of subnet IDs to launch resources in."
}

variable "vpc_id" {
  type        = "string"
  description = "ID of the target VPC."
}

## Cluster parameters

### LC parameters
variable "ami_override" {
  type        = "string"
  description = "Custom Amazon Machine Image (AMI) to associate with the launch configuration."
  default     = ""
}

variable "associate_public_ip_address" {
  type        = "string"
  description = "Flag for associating public IP addresses with instances managed by the auto scaling group."
  default     = ""
}

variable "ebs_optimized" {
  type        = "string"
  description = "Flag to enable EBS optimization."
  default     = "false"
}

variable "ebs_vol_del_on_term" {
  type        = "string"
  description = "Whether the volume should be destroyed on instance termination."
  default     = "true"
}

variable "ebs_vol_device_name" {
  type        = "string"
  description = "The name of the device to mount."
  default     = ""
}

variable "ebs_vol_encrypted" {
  type        = "string"
  description = "Whether the volume should be encrypted or not. Do not use this option if you are using 'ebs_vol_snapshot_id' as the encrypted flag will be determined by the snapshot."
  default     = ""
}

/*
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html
For the best per-I/O latency experience, we recommend that you provision an IOPS-to-GiB ratio greater than 2:1. For example, a 2,000 IOPS volume should be smaller than 1,000 GiB.
*/
variable "ebs_vol_iops" {
  type        = "string"
  description = "The amount of provisioned IOPS. Only utilized with 'ebs_vol_type' of 'io1'."
  default     = "2000"
}

variable "ebs_vol_size" {
  type        = "string"
  description = "The size of the volume in gigabytes."
  default     = ""
}

variable "ebs_vol_snapshot_id" {
  type        = "string"
  description = "The Snapshot ID to mount."
  default     = ""
}

variable "ebs_vol_type" {
  type        = "string"
  description = "The type of volume. Valid values are 'standard', 'gp2' and 'io1'."
  default     = "gp2"
}

variable "enable_monitoring" {
  type        = "string"
  description = "Flag to enable detailed monitoring."
  default     = ""
}

variable "iam_path" {
  type        = "string"
  description = "The path to the IAM resource."
  default     = "/"
}

variable "instance_based_naming_enabled" {
  type        = "string"
  description = "Flag to enable instance-id based name tagging. Requires the AWS CLI to be installed on the instance. Currently only supports Linux based systems."
  default     = ""
}

variable "instance_name_prefix" {
  type        = "string"
  description = "String to prepend instance-id based name tags with."
  default     = ""
}

variable "instance_tags" {
  type        = "map"
  description = "Map of tags to add to instances. Requires the AWS CLI to be installed on the instance. Currently only supports Linux based systems."

  default = {
    "" = ""
  }
}

variable "instance_type" {
  type        = "string"
  description = "The EC2 instance type to associate with the launch configuration."
}

variable "key_name" {
  type        = "string"
  description = "The SSH key pair to associate with the launch configuration."
  default     = ""
}

variable "logs_bucket_enabled" {
  type        = "string"
  description = "Flag for enabling access to the logs bucket from the instances."
  default     = "false"
}

variable "logs_bucket_name" {
  type        = "string"
  description = "Name of the S3 bucket for logging."
  default     = ""
}

variable "placement_tenancy" {
  type        = "string"
  description = "The tenancy of the instance. Valid values are 'default' or 'dedicated'."
  default     = "default"
}

variable "root_vol_del_on_term" {
  type        = "string"
  description = "Whether the volume should be destroyed on instance termination."
  default     = "true"
}

/*
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html
For the best per-I/O latency experience, we recommend that you provision an IOPS-to-GiB ratio greater than 2:1. For example, a 2,000 IOPS volume should be smaller than 1,000 GiB.
*/
variable "root_vol_iops" {
  type        = "string"
  description = "The amount of provisioned IOPS. Only utilized with 'root_vol_type' of 'io1'"
  default     = "2000"
}

variable "root_vol_size" {
  type        = "string"
  description = "The size of the volume in gigabytes."
  default     = ""
}

variable "root_vol_type" {
  type        = "string"
  description = "The type of volume. Valid values are 'standard', 'gp2' and 'io1'."
  default     = "gp2"
}

variable "security_groups" {
  type        = "list"
  description = "A list of security group IDs to associate with the instances."
  default     = []
}

variable "spot_price" {
  type        = "string"
  description = "The price to use for reserving spot instances."
  default     = ""
}

variable "user_data_override" {
  type        = "string"
  description = "Custom instance initialization data to associate with the launch configuration."
  default     = ""
}

### ASG parameters
variable "default_cooldown" {
  type        = "string"
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
  default     = ""
}

variable "desired_capacity" {
  type        = "string"
  description = "The number of Amazon EC2 instances that should be running in the group."
  default     = ""
}

variable "enabled_metrics" {
  type        = "list"
  description = "A list of metrics to collect. The allowed values are 'GroupMinSize', 'GroupMaxSize', 'GroupDesiredCapacity', 'GroupInServiceInstances', 'GroupPendingInstances', 'GroupStandbyInstances', 'GroupTerminatingInstances', 'GroupTotalInstances'."
  default     = []
}

variable "force_delete" {
  type        = "string"
  description = "Flag to allow deletion of the auto scaling group without waiting for all instances in the pool to terminate."
  default     = "false"
}

variable "hc_check_type" {
  type        = "string"
  description = "Type of health check performed by the auto scaling group. Valid values are 'ELB' or 'EC2'."
  default     = ""
}

variable "hc_grace_period" {
  type        = "string"
  description = "Time allowed after an instance comes into service before checking health."
  default     = ""
}

variable "max_size" {
  type        = "string"
  description = "The maximum number of instances allowed by the auto scaling group."
}

variable "min_size" {
  type        = "string"
  description = "The minimum number of instance to be maintained by the auto scaling group."
}

variable "placement_group" {
  type        = "string"
  description = "The name of the placement group into which you'll launch your instances, if any."
  default     = ""
}

variable "protect_from_scale_in" {
  type        = "string"
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events."
  default     = ""
}

variable "suspended_processes" {
  type        = "list"
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are 'Launch', 'Terminate', 'HealthCheck', 'ReplaceUnhealthy', 'AZRebalance', 'AlarmNotification', 'ScheduledActions', 'AddToLoadBalancer'. Note that if you suspend either the 'Launch' or 'Terminate' process types, it can prevent your autoscaling group from functioning properly."
  default     = []
}

variable "target_group_arns" {
  type        = "list"
  description = "A list of 'aws_alb_target_group' ARNs, for use with Application Load Balancing"
  default     = []
}

variable "termination_policies" {
  type        = "list"
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are 'OldestInstance', 'NewestInstance', 'OldestLaunchConfiguration', 'ClosestToNextInstanceHour', 'Default'."
  default     = []
}

variable "wait_for_capacity_timeout" {
  type        = "string"
  description = "A maximum duration that Terraform should wait for ASG managed instances to become healthy before timing out."
  default     = ""
}

## Service discovery parameters
variable "agent_config_override" {
  type        = "string"
  description = "Consul agent ECS task configuration JSON."
  default     = ""
}

variable "agent_task_arn_override" {
  type        = "string"
  description = "Consul agent ECS task ARN."
  default     = ""
}

variable "consul_dc" {
  type        = "string"
  description = "Consul datacenter of the specified cluster."
  default     = "dc1"
}

variable "consul_docker_image" {
  type        = "string"
  description = "Consul Docker image and tag"
  default     = "consul:latest"
}

variable "consul_gossip_cidrs" {
  type        = "list"
  description = "CIDRs encompassing all nodes wihin the Consul datacenter."
  default     = ["0.0.0.0/0"]
}

variable "registrator_config_override" {
  type        = "string"
  description = "Registrator ECS task configuration JSON."
  default     = ""
}

variable "registrator_docker_image" {
  type        = "string"
  description = "Registrator Docker image and tag"
  default     = "gliderlabs/registrator:v7"
}

variable "registrator_task_arn_override" {
  type        = "string"
  description = "Registrator ECS task ARN."
  default     = ""
}

variable "server_config_override" {
  type        = "string"
  description = "Consul server ECS task configuration JSON."
  default     = ""
}

variable "server_task_arn_override" {
  type        = "string"
  description = "Consul server ECS task ARN."
  default     = ""
}

variable "server_desired_count" {
  type        = "string"
  description = "The number of Consul server containers to run."
  default     = "3"
}

variable "service_discovery_enabled" {
  type        = "string"
  description = "Flag for the deployment of Consul service discovery and configuration."
  default     = "false"
}

variable "service_registration_enabled" {
  type        = "string"
  description = "Flag for the deployment of Registrator service registration."
  default     = "false"
}
