## Unreleased

#### IMPROVEMENTS / NEW FEATURES:
* Add support for application auto scaling

## 0.3.3 (March 10, 2019)

#### BACKWARDS INCOMPATIBILITIES / NOTES:
##### [terraform-provider-aws v2.0](https://github.com/terraform-providers/terraform-provider-aws/blob/master/CHANGELOG.md) Updates
* The [terraform-provider-aws](https://github.com/terraform-providers/terraform-provider-aws/issues/7697) has deprecated the use of the `current` filter in regions. The `current` filter was removed for [issue#7](https://github.com/unifio/terraform-aws-ecs/issues/8).
* The [terraform-provider-aws](https://github.com/terraform-providers/terraform-provider-aws/issues/5576) now requires an `owners` argument. This was added in place of the owner-alias for [issue#8](https://github.com/unifio/terraform-aws-ecs/issues/8)
* Updated [terraform-aws-asg](https://github.com/unifio/terraform-aws-asg/releases/tag/v0.3.7) to v0.3.7

## 0.3.2 (March 9, 2018)

#### BACKWARDS INCOMPATIBILITIES / NOTES:
* The `consul_gossip_cidrs` parameter has been removed.

#### IMPROVEMENTS / NEW FEATURES:
* Module now properly supports the service discovery use case of a Consul server count of 0.
* Consul communications are now bound by security group and not CIDR

## 0.3.1 (June 29, 2017)

#### BACKWARDS INCOMPATIBILITIES / NOTES:
* Cluster module no longer accepts a pre-provisioned ALB when service discovery is enabled.
* Consul ALB listener rule no longer provisioned by this module.

#### IMPROVEMENTS / NEW FEATURES:
* Upgraded `terraform-aws-asg` module to v0.3.1.
* Cluster module no longer requires a pre-provisioned ALB when service discovery is enabled. The module now returns a security group ID and target group ARN for association with an ALB at a later time if desired.
* The cluster module will now accept a list of additional target group ARNs.
* Consul ECS service role updated to AWS best practices for IAM policy.

## 0.3.0 (April 26, 2017)

#### BACKWARDS INCOMPATIBILITIES / NOTES:
* Versions of Terraform prior to v0.9.0 no longer supported.
* The following input variables have been changed:
  * `cluster_name (string, required)` -> `cluster_label (string, required)`

#### IMPROVEMENTS / NEW FEATURES:
* Support for dpeloyment of Consul service discovery & configuration.
* Support for deployment of Registrator for service registration with Consul.

## 0.2.0 (April 9, 2017)

#### BACKWARDS INCOMPATIBILITIES / NOTES:
* Versions of Terraform prior to v0.8.0 no longer supported.
* The `common` module has been removed. Similar functionality has been moved into the `cluster` module. Existing resources will be recreated in an update.
* The following input variables have been changed:
  * `agent_role_name (string, required)` -> (Removed. Use the `agent_role_id` output to add additional policies.)
  * `ami (string, required)` -> `ami_override (string, optional)`
  * `domain (string, optional)` -> Removed
  * `ecs_config (string, optional)` -> (Removed. Use `user_data_override` to specify custom configuraton.)
  * `hc_grace_period (string, default: 420)` -> `hc_grace_period (string, optional)`
  * `instance_type (string, default: t2.small)` -> `instance_type (string, required)`
  * `key_name (string, required)` -> `key_name (string, optional)`
  * `max_size (string, default: 3)` -> `max_size (string, required)`
  * `min_size (string, default: 3)` -> `min_size (string, required)`
  * `subnets (string, required)` -> `subnets (list, required)`

#### IMPROVEMENTS / NEW FEATURES:
* Module now provides a default ECS configuration to the cluster hosts in the abscense of user supplied `user_data`.
* The following parameters are now configurable:
  * `associate_public_ip_address`
  * `default_cooldown`
  * `desired_capacity`
  * `ebs_optimized`
  * `ebs_vol_del_on_term`
  * `ebs_vol_device_name`
  * `ebs_vol_encrypted`
  * `ebs_vol_iops`
  * `ebs_vol_size`
  * `ebs_vol_snapshot_id`
  * `ebs_vol_type`
  * `enable_monitoring`
  * `enabled_metrics`
  * `force_delete`
  * `iam_path`
  * `instance_based_naming_enabled`
  * `instance_name_prefix`
  * `instance_tags`
  * `logs_bucket_enabled`
  * `logs_bucket_name`
  * `placenment_group`
  * `placement_tenancy`
  * `protect_from_scale_in`
  * `root_vol_del_on_temr`
  * `root_vol_iops`
  * `root_vol_size`
  * `root_vol_type`
  * `security_groups`
  * `spot_price`
  * `suspended_processes`
  * `termination_policies`
  * `user_data_override`
  * `wait_for_capacity_timeout`
