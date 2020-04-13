name = "demo-cg"

dns_name = "capital-group.demo-gl.com"

aws_region = "eu-west-1"
aws_zones  = [
  "eu-west-1a",
  "eu-west-1b",
  "eu-west-1c",
]

cidr = "10.0.0.0/16"

private_subnets_cidrs = [
  "10.0.10.0/24",
  "10.0.11.0/24",
  "10.0.12.0/24",
]
public_subnets_cidrs  = [
  "10.0.0.0/24",
  "10.0.1.0/24",
  "10.0.2.0/24",
]

tags = {
  Owner = "GlobalLogic practices"
}
