# Outputs

output "sg_id" {
  value = "${join(",", compact(aws_security_group.consul_sg.*.id))}"
}

output "target_group_arn" {
  value = "${join(",", compact(aws_alb_target_group.consul_group.*.arn))}"
}
