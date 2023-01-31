variable "private_subnets" {
  type = list(string)
  default = ["one", "two"]
}
variable "default_security_group_id" {}
variable "vpc_id" {}
variable "public_subnets" {
  type = list(string)
  default = ["one", "two"]
}
variable "bastion_private_ip" {}
