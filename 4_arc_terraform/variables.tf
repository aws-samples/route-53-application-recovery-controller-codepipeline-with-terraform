variable "aws_region_1" {
  description = "The AWS region to create things in."
}

variable "aws_region_2" {
  description = "The AWS region to create things in."
}

variable "aws_profile" {
  description = "AWS profile"
}

variable "stack" {
  description = "Name of the stack."
}

variable "LoadBalancer1" {
  type = string
}

variable "LoadBalancer2" {
  type = string
}

variable "DynamoDBTable" {
  type = string
}

variable "DynamoDBTable_Region2" {
  type = string
}

variable "AutoScalingGroup1" {
  type = string
}

variable "AutoScalingGroup2" {
  type = string
}

variable "DNSDomainName" {
  type = string
}

variable "DNSHostedZone" {
  type = string
}

variable "LoadBalancerDNSNameEast" {
  type = string
}

variable "LoadBalancerDNSNameWest" {
  type = string
}

variable "LoadBalancerHostedZoneEast" {
  type = string
}

variable "LoadBalancerHostedZoneWest" {
  type = string
}
