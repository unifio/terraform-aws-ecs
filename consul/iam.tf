# Consul service discovery & configuration

## Creates IAM role for Consul ECS services
data "aws_iam_policy_document" "consul_policy" {
  count = local.service_discovery_check

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "consul_role" {
  count = local.service_discovery_check

  assume_role_policy = data.aws_iam_policy_document.consul_policy[0].json
  name               = "consul-${var.stack_item_label}-${data.aws_region.current.name}"
  path               = var.iam_path
}

data "aws_iam_policy_document" "consul_ec2_policy" {
  count = local.service_discovery_check

  statement {
    actions = [
      "ec2:Describe*",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "consul_ec2_policy" {
  count = local.service_discovery_check

  name   = "ec2"
  policy = data.aws_iam_policy_document.consul_ec2_policy[0].json
  role   = aws_iam_role.consul_role[0].id
}

## Creates IAM role for the ECS service
data "aws_iam_policy_document" "ecs_policy" {
  count = local.service_discovery_check * local.consul_server_check

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  count = local.service_discovery_check * local.consul_server_check

  assume_role_policy = data.aws_iam_policy_document.ecs_policy[0].json
  name               = "ecs-consul-${var.stack_item_label}-${data.aws_region.current.name}"
  path               = var.iam_path
}

data "aws_iam_policy_document" "lb_policy" {
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lb_policy" {
  count = local.service_discovery_check * local.consul_server_check

  name   = "lb"
  policy = data.aws_iam_policy_document.lb_policy.json
  role   = aws_iam_role.ecs_role[0].id
}

data "aws_iam_policy_document" "ecs_ec2_policy" {
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_ec2_policy" {
  count = local.service_discovery_check * local.consul_server_check

  name   = "ec2"
  policy = data.aws_iam_policy_document.ecs_ec2_policy.json
  role   = aws_iam_role.ecs_role[0].id
}

