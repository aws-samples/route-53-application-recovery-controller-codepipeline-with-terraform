module "application_stack" {
  source = "../../modules/application_stack"

  aws_region    = "${var.aws_region_2}"
  stack         = "${var.stack}"
  aws_profile   = "${var.aws_profile}"
}

output "alb-arn" {
  value = "${module.application_stack.alb.arn}"
}

output "alb-dns-name" {
  value = "${module.application_stack.alb.dns_name}"
}

output "alb-zone-id" {
  value = "${module.application_stack.alb.zone_id}"
}

output "asg-arn" {
  value = "${module.application_stack.asg.arn}"
}
