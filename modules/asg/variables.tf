variable "name" {
    type = string
    description = "name of the launch config"
    default = "dev-asg"
}

variable "instance_type" {
    type = string
    description = "type of ec2 instance"
    default = "t2.micro"
}

variable "min_size" {
    type = number
    description = "minimum no of ec2 instances for asg scale in"
    default = 2
}
variable "max_size" {
    type = number
    description = "max number of ec2 instances asg can scale out"
    default = 5
}

variable "desired_capacity" {
    type = number
    description = "no of ec2 instances should run always"
    default = 3
}

variable "target_group_names" {
  type    = list(string)
  default = ["web-tg-0", "web-tg-1", "web-tg-2"]
}

variable "environment" {
    type = string
    default = "dev"
}