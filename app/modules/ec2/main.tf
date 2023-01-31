module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.name

  ami                         = "ami-0a261c0e5f51090b1"
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  vpc_security_group_ids      = [var.default_security_group_id]
  subnet_id                   = var.subnet_id
  user_data                   = var.user_data
  associate_public_ip_address = var.has_public_ip
  iam_instance_profile        = var.iam_instance_profile
  tags = var.tags
}