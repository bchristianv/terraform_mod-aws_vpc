# Variable definitions

variable "aws_region" {
  type        = string
  description = "The AWS region in which to perform configuration operations"
  default     = "us-east-1"
}

variable "az_private_subnets" {
  type        = map(map(number))
  description = "Private subnets map of region AZ ID to subnet bits and network number, eg: {b = { sbits = 8, net = 1 }}"
  default     = {}
}

variable "az_public_subnets" {
  type        = map(map(number))
  description = "Public subnets map of region AZ ID to subnet bits and network number, eg: {a = { sbits = 8, net = 1 }}"
  default     = {}
}

variable "cidr" {
  type        = string
  description = "The IP block in CIDR notation for this VPC"
  validation {
    condition     = can(regex("((\\d{1,3})\\.){3}\\d{1,3}/\\d{1,2}", var.cidr))
    error_message = "The IP block must be valid CIDR notation."
  }
}

variable "default_security_group_egress" {
  type        = list(map(string))
  description = "List of egress rule mappings for the VPC default security group"
  default     = [{ from_port = 0, to_port = 0, protocol = -1, cidr_blocks = "0.0.0.0/0" }]
}

variable "default_security_group_ingress" {
  type        = list(map(string))
  description = "List of ingress rule mappings for the VPC default security group"
  default     = [{ from_port = 0, to_port = 0, protocol = -1, self = true }]
}

variable "internal_dns_domainname" {
  type        = string
  description = "The domain name for the Route53 internal hosted zone"
}

variable "name" {
  type        = string
  description = "The value to use for the VPC `Name` tag"
}
