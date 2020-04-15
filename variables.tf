variable "aws_profile" {
  type = string

  default = "default"
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)

  default = {}
}

variable "dns_name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_zones" {
  type = list(string)
}

variable "private_subnets_cidrs" {
  type = list(string)
}

variable "public_subnets_cidrs" {
  type = list(string)
}

variable "ansible_run" {
  type = bool

  default = false
}

variable "ansible_trigger" {
  type = string

  default = ""
}

variable "ansible_arguments" {
  type = string

  default = ""
}
