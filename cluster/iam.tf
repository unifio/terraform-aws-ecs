# Elastic Container Service (ECS) cluster

## Creates IAM role for agent instances
data "aws_iam_policy_document" "role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  assume_role_policy = "${data.aws_iam_policy_document.role.json}"
  name_prefix        = "${var.cluster_name}-${var.stack_item_label}-${data.aws_region.current.name}-"
  path               = "${var.iam_path}"
}

resource "aws_iam_instance_profile" "profile" {
  name_prefix = "${var.cluster_name}-${var.stack_item_label}-${data.aws_region.current.name}-"
  path        = "${var.iam_path}"
  roles       = ["${aws_iam_role.role.name}"]
}

### Creates monitoring policy
data "aws_iam_policy_document" "monitoring" {
  statement {
    actions = [
      "cloudwatch:*",
      "logs:*",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "monitoring" {
  name   = "monitoring"
  policy = "${data.aws_iam_policy_document.monitoring.json}"
  role   = "${aws_iam_role.role.id}"
}

### Creates resource tagging policy
data "aws_iam_policy_document" "tagging" {
  statement {
    actions   = ["ec2:CreateTags"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "tagging" {
  name   = "tagging"
  policy = "${data.aws_iam_policy_document.tagging.json}"
  role   = "${aws_iam_role.role.id}"
}

### Creates Elastic Container Service (ECS) service policy
data "aws_iam_policy_document" "ecs" {
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

resource "aws_iam_role_policy" "ecs" {
  name   = "ecs"
  policy = "${data.aws_iam_policy_document.ecs.json}"
  role   = "${aws_iam_role.role.id}"
}

### Creates Simple Storage Service (S3) policy for logging buckets
data "aws_iam_policy_document" "logging" {
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

resource "aws_iam_role_policy" "logging" {
  count = "${var.logs_bucket_enabled == "true" ? "1" : "0"}"

  name   = "logging"
  policy = "${data.aws_iam_policy_document.logging.json}"
  role   = "${aws_iam_role.role.id}"
}
