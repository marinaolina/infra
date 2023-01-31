locals {
  region = "<%= expansion(:REGION) %>"
  env = "<%= Terraspace.env %>"
  prefix = "marina"
  tags = {
    env = local.env
    Terraform = "true"
  }
}