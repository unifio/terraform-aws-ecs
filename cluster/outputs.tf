# Outputs

output "agent_role_id" {
  value = "${aws_iam_role.agent_role.id}"
}

output "cluster_id" {
  value = "${aws_ecs_cluster.cluster.id}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.cluster.name}"
}

output "sg_id" {
  value = "${module.cluster.sg_id}"
}
