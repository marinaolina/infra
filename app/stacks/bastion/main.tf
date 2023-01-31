module "bastion" {
  source = "../../modules/ec2"

  name          = "${local.prefix}-bastion"
  instance_type = "t2.micro"
  key_name      = "marina_key_pem"

  default_security_group_id = var.default_security_group_id
  subnet_id                 = var.public_subnets[0]
  has_public_ip             = true
  tags                      = local.tags


}

