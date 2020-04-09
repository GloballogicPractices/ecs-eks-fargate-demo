variable "aws_profile" {
  type = string

  default = "gl"
}

variable "name" {
  type = string

  default = "demo-eks-fargate"
}

variable "cidr" {
  type = string

  default = "10.0.0.0/16"
}

variable "aws_region" {
  type = string

  default = "eu-west-1"
}

variable "aws_zones" {
  type = list(string)

  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c",
  ]
}

variable "private_subnets_cidrs" {
  type = list(string)

  default = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
  ]
}

variable "public_subnets_cidrs" {
  type = list(string)

  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}
