# Outputs

output "cluster_id" {
  value = "${aws_ecs_cluster.application.id}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.application.name}"
}

output "sg_id" {
  value = "${module.cluster.sg_id}"
}
