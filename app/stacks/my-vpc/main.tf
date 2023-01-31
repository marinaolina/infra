module "vpc" {
  source = "../../modules/vpc"

  name = "${local.prefix}-vpc"
  cidr = var.cidr

  azs             = ["eu-central-1a", "eu-central-1b"]
  public_subnets = [
    cidrsubnet(var.cidr, 8, 0),
    cidrsubnet(var.cidr, 8, 1)
  ]
  private_subnets = [
    cidrsubnet(var.cidr, 8, 2),
    cidrsubnet(var.cidr, 8, 3)
  ]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags

}


resource "aws_security_group_rule" "ssh" {
  protocol          = "TCP"
  from_port         = 22
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = var.allowed_hosts
  security_group_id = module.vpc.default_security_group_id
}
