# Terraform AWS ECS Stack #
[![Circle CI](https://circleci.com/gh/unifio/terraform-aws-ecs/tree/master.svg?style=svg)](https://circleci.com/gh/unifio/terraform-aws-ecs/tree/master)

Terraform module for the deployment of an AWS ECS cluster.

## Requirements ##

- Terraform 0.6.16 or newer
- AWS provider

## Common Module ##

The common module provisions the following resources for use with the ECS cluster:

- IAM role & instance profile
- Default policies
- S3 bucket for ECS logs

These resources can be shared amongst multiple clusters if desired.

### Input Variables ###

Name | Type | Default | Description
--- | --- | --- | ---
`bucket_prefix` | string | | Label to prepend S3 bucket names with.
`stack_item_fullname` | string | | Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item.
`stack_item_label` | string | | Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use.

### Usage ###

```js
module "ecs" {
  source = "github.com/unifio/terraform-aws-ecs?ref=master//common"

  bucket_prefix       = "xmplco"
  stack_item_fullname = "Example Cluster"
  stack_item_label    = "xmpl"
}
```

### Outputs ###

Name | Type | Description
--- | --- | --- | ---
`ecs_agent_role_arn` | string | ARN of the ECS IAM role.
`ecs_agent_role_id` | string | ID of the ECS IAM role.
`ecs_agent_role_name` | string | Name of the ECS IAM role.
`ecs_agent_role_unique_id` | string | Unique ID of the ECS IAM role.
`ecs_logs_bucket_name` | string | Name of the ECS S3 logs bucket.

## Cluster module ##

The cluster module provisions an ECS cluster and auto scaling group of agent instances.

### Input Variables ###

Name | Type | Default | Description
--- | --- | --- | ---
`agent_role_name` | string | | Name of the IAM role to be associated with the cluster members.
`ami` | string | | Amazon Machine Image (AMI) of the cluster host.
`cluster_name` | string | | Name of the ECS based application stack.
`domain` | string | "" | The suffix domain name.
`ecs_config` | string | "" | ECS agent configuration.
`hc_check_type` | string | EC2 | Type of health check performed by the cluster. Valid values are 'ELB' or 'EC2'.
`hc_grace_period` | string | 420 | Time allowed after an instance comes into service before checking health.
`instance_type` | string | t2.small | EC2 instance type to associate with the cluster members.
`key_name` | string | | SSH key pair to associate with the cluster members.
`max_size` | string | 3 | Maximum number of instances allowed by the cluster.
`min_size` | string | 3 | Minimum number of instances allowed by the cluster.
`region` | string | us-east-1 | AWS region to be utilized.
`stack_item_fullname` | string | | Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item.
`stack_item_label` | string | | Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use.
`subnets` | string | | List of VPC subnets to associate with the auto scaling group.
`user_data` | string | "" | Instance initialization data to associate with the cluster members.
`vpc_id` | string | | ID of the target VPC.

### Usage ###

```js
module "cluster" {
  source = "github.com/unifio/terraform-aws-ecs?ref=master//cluster"

  agent_role_name     = "ecs"
  ami                 = "ami-xxxxxxxx"
  cluster_name        = "xmpl-prod"
  domain              = "service.consul"
  instance_type       = "t2.small"
  key_name            = "xmplprd"
  max_size            = "3"
  min_size            = "3"
  region              = "us-east-1"
  stack_item_fullname = "Example Cluster"
  stack_item_label    = "xmpl"
  subnets             = "subnet-aaaaaaaa,subnet-bbbbbbbb,subnet-cccccccc"
  vpc_id              = "vpc-xxxxxxxx" 
}
```

### Outputs ###

Name | Type | Description
--- | --- | --- | ---
`cluster_id` | string | ID of the ECS cluster
`cluster_name` | string | Name of the ECS cluster
`sg_id` | string | ID of the security group associated with the agent instances.

## Examples ##

See the [examples](examples) directory for a complete set of example source files.

## License ##

MPL 2. See [LICENSE](./LICENSE) for full details.
