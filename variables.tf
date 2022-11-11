variable "env_code" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_cidr" {
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "route_cidr" {
  default = "0.0.0.0/0"
}

variable "instance_type" {
  default = "t2.micro"
}