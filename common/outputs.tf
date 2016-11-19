# Outputs

output "ecs_agent_role_arn" {
  value = "${aws_iam_role.role_ecs_agent.arn}"
}

output "ecs_agent_role_id" {
  value = "${aws_iam_role.role_ecs_agent.id}"
}

output "ecs_agent_role_name" {
  value = "ecs-agent-${var.stack_item_label}"
}

output "ecs_agent_role_unique_id" {
  value = "${aws_iam_role.role_ecs_agent.unique_id}"
}

output "ecs_logs_bucket_name" {
  value = "${aws_s3_bucket.bucket_ecs_logs.id}"
}
