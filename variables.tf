variable "vpc_id" {
  default=""
  type= string
}
variable "vpc_subnets" {
  description = "List of subnets to put instances in"
  type = list(string)
  default     = ["",""]
}
variable "aws_region" {
  type        = string
  description = "AWS Region"
  default = "us-west-2"
}
variable "vpc_private_subnets" {
  description = "private subnets"
  default     = ["",""]
}


variable "app_name" {
  type        = string
  description = "Application Name"
  default = "factorial"
}

variable "app_environment" {
  type        = string
  description = "Application Environment"
  default = "dev"
}
