variable "name" {}
variable "instance_type" {}
variable "key_name" {}
variable "default_security_group_id" {}
variable "subnet_id" {}
variable "tags" {}
variable "user_data" {
  default = null
}

variable "has_public_ip" {
  default = false
}

variable "iam_instance_profile" {
  default=""
}