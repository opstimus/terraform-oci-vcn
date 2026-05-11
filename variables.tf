variable "project" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)."
  type        = string
}

variable "tenancy_id" {
  description = "The OCID of the tenancy."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment where the VCN will be created."
  type        = string
}

variable "vcn_cidr_blocks" {
  description = "The CIDR blocks for the VCN."
  type        = list(string)
}

variable "public_subnets" {
  description = "A map of public subnet names to their CIDR blocks."
  type        = map(string)
}

variable "private_subnets" {
  description = "A map of private subnet names to their CIDR blocks."
  type        = map(string)
}

variable "tags" {
  description = "Free-form tags to apply to the VCN."
  type        = map(string)
  default     = null
}
