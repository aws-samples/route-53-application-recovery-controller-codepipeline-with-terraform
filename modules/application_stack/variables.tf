# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to create things in."
}

variable "aws_profile" {
  description = "AWS profile"
}

variable "stack" {
  description = "Name of the stack."
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "alb_listener_port" {
  default     = 80
}

variable "app_port" {
  default     = 3000
}
