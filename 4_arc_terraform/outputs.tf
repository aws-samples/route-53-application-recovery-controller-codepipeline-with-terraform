output "Cell1" {
  value = aws_route53recoveryreadiness_cell.Cell1
}

output "Cell2" {
  value = aws_route53recoveryreadiness_cell.Cell2
}

output "Cluster" {
  value = aws_route53recoverycontrolconfig_cluster.Cluster
}

output "RoutingControlCell1" {
  value = aws_route53recoverycontrolconfig_routing_control.RoutingControlCell1
}

output "RoutingControlCell2" {
  value = aws_route53recoverycontrolconfig_routing_control.RoutingControlCell2
}

output "HealthCheckCell1" {
  value = aws_route53_health_check.HealthCheckCell1
}

output "HealthCheckCell2" {
  value = aws_route53_health_check.HealthCheckCell2
}

output "DNSRecordNamePrimary" {
  value = aws_route53_record.FrontEndAliasRecordPrimary
}

output "DNSRecordNameSecondary" {
  value = aws_route53_record.FrontEndAliasRecordSecondary
}