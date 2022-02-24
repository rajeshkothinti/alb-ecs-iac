variable "vpc_id" {
  default="vpc-0fe60e8ce29e2a4c2"
  type= string
}
variable "vpc_subnets" {
  description = "List of subnets to put instances in"
  type = list(string)
  default     = ["subnet-0529987600c3f53b8","subnet-0012144a606d1140c"]
}
variable "aws_region" {
  type        = string
  description = "AWS Region"
  default = "us-west-2"
}
variable "vpc_private_subnets" {
  description = "private subnets"
  default     = ["subnet-0529987600c3f53b8","subnet-0012144a606d1140c"]
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