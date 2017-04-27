# Terraform AWS ECS Stack #
[![Circle CI](https://circleci.com/gh/unifio/terraform-aws-ecs/tree/master.svg?style=svg)](https://circleci.com/gh/unifio/terraform-aws-ecs/tree/master)

Terraform module for the deployment of an AWS Elastic Container Service (ECS) cluster.

## Requirements ##

- Terraform 0.8.0 or newer
- AWS provider

## Cluster module ##

The cluster module provisions an ECS cluster and auto scaling group of agent instances.

### Input Variables ###

#### Resource tags
Name | Type | Required | Description
--- | --- | --- | ---
`cluster_label` | string | yes | Short form identifier for this cluster.
`stack_item_fullname` | string | yes | Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item.
`stack_item_label` | string | yes | Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use.

#### VPC parameters
Name | Type | Required | Description
--- | --- | --- | ---
`subnets` | list | yes | A list of subnet IDs to launch resources in.
`vpc_id` | string | yes | ID of the target VPC.

#### Cluster launch configuration parameters
Name | Type | Required | Description
--- | --- | --- | ---
`ami_override` | string | | Custom Amazon Machine Image (AMI) to associate with the launch configuration.
`associate_public_ip_address` | string | | Flag for associating public IP addresses with instances managed by the auto scaling group.
`ebs_optimized` | string | | Flag to enable EBS optimization.
`ebs_vol_del_on_term` | string | Default: `true` | Whether the volume should be destroyed on instance termination.
`ebs_vol_device_name` | string | | The name of the device to mount.
`ebs_vol_encrypted` | string | | Whether the volume should be encrypted or not. Do not use this option if you are using `ebs_vol_snapshot_id` as the encrypted flag will be determined by the snapshot.
`ebs_vol_iops` | string | Default: `2000` | The amount of provisioned IOPS. Only utilized with `ebs_vol_type` of `io1`.
`ebs_vol_size` | string | | The size of the volume in gigabytes.
`ebs_vol_snapshot_id` | string | | The Snapshot ID to mount.
`ebs_vol_type` | string | Default: `gp2` | The type of volume. Valid values are `standard`, `gp2` and `io1`.
`enable_monitoring` | string | | Flag to enable detailed monitoring.
`iam_path` | string | Default: `/` | The path to the IAM resource.
`instance_based_naming_enabled` | string | | Flag to enable instance-id based name tagging. Requires the AWS CLI to be installed on the instance. Currently only supports Linux based systems.
`instance_name_prefix` | string | | String to prepend instance-id based name tags with.
`instance_tags` | map | | Map of tags to add to instances. Requires the AWS CLI to be installed on the instance. Currently only supports Linux based systems.
`instance_type` | string | yes | The EC2 instance type to associate with the launch configuration.
`key_name` | string | | The SSH key pair to associate with the launch configuration.
`logs_bucket_enabled` | string | Default: `false` | Flag for enabling access to the logs bucket from the instances.
`logs_bucket_name` | string | | Name of the S3 bucket for logging.
`placement_tenancy` | string | Default: `default` | The tenancy of the instance. Valid values are `default` or `dedicated`.
`root_vol_del_on_term` | string | Default: `true` | Whether the volume should be destroyed on instance termination.
`root_vol_iops` | string | Default: `2000` | The amount of provisioned IOPS. Only utilized with `root_vol_type` of `io1`.
`root_vol_size` | string | | The size of the volume in gigabytes.
`root_vol_type` | string | Default: `gp2` | The type of volume. Valid values are `standard`, `gp2` and `io1`.
`security_groups` | list | Default: [] | A list of security group IDs to associate with the instances.
`spot_price` | string | | The price to use for reserving spot instances.
`user_data_override` | string | | Custom instance initialization data to associate with the launch configuration.

#### Cluster auto scaling group parameters
Name | Type | Required | Description
--- | --- | --- | ---
`default_cooldown` | string | | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start.
`desired_capacity` | string | | The number of Amazon EC2 instances that should be running in the group.
`enabled_metrics` | string | Default: [] | A list of metrics to collect. The allowed values are `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupTerminatingInstances`, `GroupTotalInstances`.
`force_delete` | string | Default: `false` | Flag to allow deletion of the auto scaling group without waiting for all instances in the pool to terminate.
`hc_check_type` | string | | Type of health check performed by the auto scaling group. Valid values are `ELB` or `EC2`.
`hc_grace_period` | string | | Time allowed after an instance comes into service before checking health.
`max_size` | string | yes | The maximum number of instances allowed by the auto scaling group.
`min_size` | string | yes | Minimum number of instance to be maintained by the auto scaling group.
`placement_group` | string | | The name of the placement group into which you'll launch your instances, if any.
`protect_from_scale_in` | string | | Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events.
`suspended_processes` | list | Default: [] | A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly.
`termination_policies` | list | Default: [] | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default`.
`wait_for_capacity_timeout` | string | | A maximum duration that Terraform should wait for ASG managed instances to become healthy before timing out.

#### Service discovery & configuration parameters
Name | Type | Required | Description
--- | --- | --- | ---
`agent_config_override` | string | | Consul agent ECS task configuration JSON.
`agent_task_arn_override` | string | | Consul agent ECS task ARN.
`consul_dc` | string | Default: `dc1` | Consul datacenter of the specified cluster.
`consul_gossip_cidrs` | list | Default: `0.0.0.0/0` | CIDRs encompassing all nodes wihin the Consul datacenter.
`lb_arn` | string | yes; if `service_discovery_enabled` is `true` | Load balancer ARN.
`lb_sg_id` | string | yes; if `service_discovery_enabled` is `true` | Consul service endpoint security group ID.
`registrator_config_override` | string | | Registrator ECS task configuration JSON.
`registrator_task_arn_override` | string | | Registrator ECS task ARN.
`server_config_override` | string | | Consul server ECS task configuration JSON.
`server_task_arn_override` | string | | Consul server ECS task ARN.
`server_desired_count` | string | Default: `3` | The number of Consul server containers to run.
`service_discovery_enabled` | string | Default: `false` | Flag for the deployment of Consul service discovery and configuration.
`service_registration_enabled` | string | Default: `false` | Flag for the deployment of Registrator service registration.

### Usage ###

```js
module "cluster" {
  source = "github.com/unifio/terraform-aws-ecs?ref=master//cluster"

  # Resource tags
  cluster_name        = "xmpl-prod"
  stack_item_fullname = "Example Cluster"
  stack_item_label    = "xmpl"

  # VPC parameters
  subnets             = ["subnet-aaaaaaaa","subnet-bbbbbbbb","subnet-cccccccc"]
  vpc_id              = "vpc-xxxxxxxx"

  # LC parameters
  iam_path                      = "/tf_managed/"
  instance_based_naming_enabled = "true"
  instance_type                 = "t2.small"

  # ASG parameters
  max_size = "3"
  min_size = "3"

  # Service discovery parameters
  service_discovery_enabled = true
  service_registration_enabled = true
  la_arn = "arn:aws:elasticloadbalancing:us-east-2:XXXXXXXXXXXX:loadbalancer/app/exmpl-cmpl/93f47d7391a68bf0"
  lb_sg_id = "sg-xxxxxxxx"
}
```

### Outputs ###

Name | Type | Description
--- | --- | ---
`agent_role_id` | string | ID of the ECS agent IAM role.
`cluster_id` | string | ID of the ECS cluster.
`cluster_name` | string | Name of the ECS cluster.
`consul_target_group_arn` | string | ARN of the Consul server target group.
`sg_id` | string | ID of the security group associated with the agent instances.

## Examples ##

See the [examples](examples) directory for a complete set of example source files.

## License ##

MPL 2. See [LICENSE](./LICENSE) for full details.
