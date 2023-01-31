variable "name" {}
variable "cidr" {}
variable "azs" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "tags" {}
variable "enable_nat_gateway" {}
variable "single_nat_gateway" {}
variable "enable_dns_hostnames" {}
variable "enable_dns_support"  {}



