#
# This template demonstrates how to configure Amazon Route53 Failover record sets that use 
# Amazon Route53 Application Recovery Controller (ARC) healthchecks
#
# For a full description of how it works, please read
# https://aws.amazon.com/fr/blogs/aws/amazon-route-53-application-recovery-controller/
# and
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs

resource "aws_route53_record" "FrontEndAliasRecordPrimary" {
  zone_id = "${var.DNSHostedZone}"
  name    = "${var.stack}.${var.DNSDomainName}"
  type    = "A"
  alias {
    name                   = "${var.LoadBalancerDNSNameEast}"
    zone_id                = "${var.LoadBalancerHostedZoneEast}" 
    evaluate_target_health = true
  }
  set_identifier =  "${var.stack}-east" 
  failover_routing_policy {
    type = "PRIMARY"
  }
  
  health_check_id = aws_route53_health_check.HealthCheckCell1.id
}

resource "aws_route53_record" "FrontEndAliasRecordSecondary" {
  zone_id = "${var.DNSHostedZone}"
  name    = "${var.stack}.${var.DNSDomainName}"
  type    = "A"
  alias {
    name                   = "${var.LoadBalancerDNSNameWest}"
    zone_id                = "${var.LoadBalancerHostedZoneWest}" 
    evaluate_target_health = true
  }
  set_identifier =  "${var.stack}-west" 
  failover_routing_policy {
    type = "SECONDARY"
  }
  
  health_check_id = aws_route53_health_check.HealthCheckCell2.id
}
