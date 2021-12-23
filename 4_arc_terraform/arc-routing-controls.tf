#
# This template demonstrates how to configure Amazon Route53 Application Recovery Controller Routing Controls
#
# ***************************************************
# RUNNING THIS TEMPLATE COSTS $60/day ($2.5/hour) 
# BE SURE TO DELETE THIS STACK WHEN NO LONGER NEEDED
# ***************************************************
#
# For a full description of how it works, please read
# https://aws.amazon.com/fr/blogs/aws/amazon-route-53-application-recovery-controller/
# and
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs

#
# The Application Recovery Controller cluster
#

resource "aws_route53recoverycontrolconfig_cluster" "Cluster" {
  name = "${var.stack}-Cluster"
}

#
# The Application Recovery Controller control panel
#

resource "aws_route53recoverycontrolconfig_control_panel" "ControlPanel" {
  name        = "${var.stack}-ControlPanel"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.Cluster.arn
}

#
# The Application Recovery Controller routing controls
#

resource "aws_route53recoverycontrolconfig_routing_control" "RoutingControlCell1" {
  name        = "${var.stack}-Cell1-${var.aws_region_1}"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.Cluster.arn
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.ControlPanel.arn
}

resource "aws_route53recoverycontrolconfig_routing_control" "RoutingControlCell2" {
  name        = "${var.stack}-Cell2-${var.aws_region_2}"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.Cluster.arn
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.ControlPanel.arn
}

#
# The Application Recovery Controller safety rules
#

resource "aws_route53recoverycontrolconfig_safety_rule" "SafetyRuleMinCellsActive" {
  asserted_controls = [aws_route53recoverycontrolconfig_routing_control.RoutingControlCell1.arn, aws_route53recoverycontrolconfig_routing_control.RoutingControlCell2.arn]
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.ControlPanel.arn
  name              = "${var.stack}-MinCellsActive"
  wait_period_ms    = 5000

  rule_config {
    inverted  = false
    threshold = 1
    type      = "ATLEAST"
  }
}

#
# Route 53 Health Checks for each cell
#

resource "aws_route53_health_check" "HealthCheckCell1" {
  routing_control_arn = aws_route53recoverycontrolconfig_routing_control.RoutingControlCell1.arn
  type                = "RECOVERY_CONTROL"
}

resource "aws_route53_health_check" "HealthCheckCell2" {
  routing_control_arn = aws_route53recoverycontrolconfig_routing_control.RoutingControlCell2.arn
  type                = "RECOVERY_CONTROL"
}
