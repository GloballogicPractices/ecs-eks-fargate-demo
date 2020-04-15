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

variable "run_on_fargate" {
  type = bool
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

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "apps" {
  type = list(object({
    name   = string
    source = string

    http = object({
      port   = number
      scheme = string
      ping   = string
    })

    portMappings = list(object({
      hostPort      = number
      containerPort = number
    }))

    cpu    = string
    memory = string

    env = list(object({
      name  = string
      value = string
    }))
  }))
}

variable "docker_repo" {
  type = string
}

variable "tags" {
  type = map(string)

  default = {}
}
