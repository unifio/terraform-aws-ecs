# Output variables

output "dmz_rt_id" {
  value = "${module.vpc_base.rt_dmz_id}"
}

output "dmz_subnet_ids" {
  value = "${module.vpc_az.dmz_ids}"
}

output "vpc_id" {
  value = "${module.vpc_base.vpc_id}"
}
