variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "project" {
  type    = string
  default = "arogya-sakhi"
}
variable "environment" { type = string }

variable "db_instance_class" { type = string }
variable "db_multi_az" { type = bool }
variable "redis_node_type" { type = string }
variable "service_desired_count" { type = number }

variable "api_gateway_image" { type = string }
variable "beneficiary_image" { type = string }
