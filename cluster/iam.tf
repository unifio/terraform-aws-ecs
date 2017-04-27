# Elastic Container Service (ECS) cluster

## Creates IAM role for agent instances
data "aws_iam_policy_document" "agent_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "agent_role" {
  assume_role_policy = "${data.aws_iam_policy_document.agent_policy.json}"
  name               = "ecs-agent-${var.cluster_label}-${var.stack_item_label}-${data.aws_region.current.name}"
  path               = "${var.iam_path}"
}

resource "aws_iam_instance_profile" "agent_profile" {
  name  = "ecs-agent-${var.cluster_label}-${var.stack_item_label}-${data.aws_region.current.name}"
  path  = "${var.iam_path}"
  roles = ["${aws_iam_role.agent_role.name}"]
}

### Creates monitoring policy
data "aws_iam_policy_document" "monitoring_policy" {
  statement {
    actions = [
      "cloudwatch:*",
      "logs:*",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "monitoring_policy" {
  name   = "monitoring"
  policy = "${data.aws_iam_policy_document.monitoring_policy.json}"
  role   = "${aws_iam_role.agent_role.id}"
}

### Creates resource tagging policy
data "aws_iam_policy_document" "tagging_policy" {
  statement {
    actions   = ["ec2:CreateTags"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "tagging_policy" {
  name   = "tagging"
  policy = "${data.aws_iam_policy_document.tagging_policy.json}"
  role   = "${aws_iam_role.agent_role.id}"
}

### Creates Elastic Container Service (ECS) service policy
data "aws_iam_policy_document" "ecs_policy" {
  statement {
    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecs:StartTask",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_policy" {
  name   = "ecs"
  policy = "${data.aws_iam_policy_document.ecs_policy.json}"
  role   = "${aws_iam_role.agent_role.id}"
}

### Creates Simple Storage Service (S3) policy for logging buckets
data "aws_iam_policy_document" "logging_policy" {
  count = "${var.logs_bucket_enabled == "true" ? "1" : "0"}"

  statement {
    actions   = ["s3:ListBucket"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.logs_bucket_name}"]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.logs_bucket_name}/*"]
  }
}

resource "aws_iam_role_policy" "logging_policy" {
  count = "${var.logs_bucket_enabled == "true" ? "1" : "0"}"

  name   = "logging"
  policy = "${data.aws_iam_policy_document.logging_policy.json}"
  role   = "${aws_iam_role.agent_role.id}"
}
