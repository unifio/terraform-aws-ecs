# Elastic Container Service (ECS) common resources

## Creates an IAM role for ECS cluster members
resource "aws_iam_role" "role_ecs_agent" {
  name = "ecs-agent-${var.stack_item_label}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    }
  }]
}
EOF
}

### Creates monitoring policy
resource "aws_iam_role_policy" "policy_monitoring" {
  name = "monitoring"
  role = "${aws_iam_role.role_ecs_agent.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "cloudwatch:*",
      "logs:*"
    ],
    "Resource": "*"
  }]
}
EOF
}

### Creates resource tagging policy
resource "aws_iam_role_policy" "policy_tagging" {
  name = "tagging"
  role = "${aws_iam_role.role_ecs_agent.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ec2:CreateTags"
    ],
    "Resource": "*"
  }]
}
EOF
}

### Creates Elastic Container Service (ECS) service policy
resource "aws_iam_role_policy" "policy_ecs" {
  name = "ecs"
  role = "${aws_iam_role.role_ecs_agent.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecs:StartTask"
    ],
    "Resource": "*"
  }]
}
EOF
}

### Creates Simple Storage Service (S3) policy for ECS buckets
resource "aws_iam_role_policy" "policy_s3" {
  name = "s3"
  role = "${aws_iam_role.role_ecs_agent.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "s3:ListBucket"
    ],
    "Resource": [
      "arn:aws:s3:::${var.bucket_prefix}-ecs-logs-${var.stack_item_label}"
    ]
  },
  {
    "Effect": "Allow",
    "Action": [
      "s3:PutObject",
      "s3:GetObject"
    ],
    "Resource": [
      "arn:aws:s3:::${var.bucket_prefix}-ecs-logs-${var.stack_item_label}/*"
    ]
  }]
}
EOF
}

## Creates S3 bucket for ECS related resource logs
resource "aws_s3_bucket" "bucket_ecs_logs" {
  bucket = "${var.bucket_prefix}-ecs-logs-${var.stack_item_label}"

  lifecycle_rule {
    id      = "Primary retention"
    prefix  = "/"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
    "Sid":"",
		"Effect": "Allow",
		"Principal": {
			"AWS": "arn:aws:iam::127311923021:root"
		},
		"Action": "s3:PutObject",
		"Resource": "arn:aws:s3:::${var.bucket_prefix}-ecs-logs-${var.stack_item_label}/*"
	}]
}
EOF

  tags {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
  }
}
