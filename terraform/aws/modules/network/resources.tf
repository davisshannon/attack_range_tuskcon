
data "aws_availability_zones" "available" {}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  cluster_name = "${var.config.range_name}_cluster-${var.config.key_name}"
  public_ip = jsondecode(data.http.my_public_ip.body)
  user_yaml = yamldecode(file("${path.module}/../../../../users.yml"))
  acl = local.user_yaml.users[*].ip
  ip_addrs = setunion(["${local.public_ip.ip}/32"],local.acl,["10.0.1.0/16"])
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = "${var.config.range_name}_vpc-${var.config.key_name}"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.1.0/16"]
  enable_dns_hostnames = true

}

resource "aws_security_group" "default" {
  name   = "${var.config.range_name}_sg_public_subnets-${var.config.key_name}"
  vpc_id = module.vpc.vpc_id

  ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.ip_addrs
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
