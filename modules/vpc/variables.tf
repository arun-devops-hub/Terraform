variable "env" {
    type = string
    description = "env for the vpc"
    default = "dev"
}

variable "app_name" {
  type = string
  description = "name of the application"
  default = "arunops"
}

variable "region" {
 type = string
 description = "name of the aws region"
 default = "ap-south-1"
}
variable "vpc_cidr" {
 type = string
 description = "cidr value for vpc"
 default = "10.2.0.0/16"
}

variable "public_subnets_cidr" {
    type = list
    description = "public subnet cidr's for vpc"
    default = ["10.2.0.0/24", "10.2.1.0/24","10.2.3.0/24"] 
}


variable "private_subnet_cidr" {
   type = list
   description = "private subnet cidr's for vpc"
   default = ["10.2.4.0/24","10.2.5.0/24","10.2.6.0/24"]
}
