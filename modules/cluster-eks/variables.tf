variable "name" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "run_on_fargate" {
  type = bool
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "artifacts_dir" {
  type = string
}

variable "ansible_run" {
  type = bool
}

variable "ansible_trigger" {
  type = string
}

variable "ansible_arguments" {
  type = string
}

variable "apps" {
  type = list(object({
    name        = string
    namespace   = string
    source      = string
    helm_values = string
  }))
}

variable "dns_name" {
  type = string
}

variable "docker_repo" {
  type = string
}

variable "tags" {
  type = map(string)

  default = {}
}
