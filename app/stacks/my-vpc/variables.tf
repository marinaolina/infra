variable "cidr" {
  default = "10.10.0.0/16"
}

variable "allowed_hosts" {
  description = "CIDR blocks of trusted networks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

