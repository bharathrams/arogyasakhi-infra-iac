variable "name" { type = string }
variable "cluster_arn" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "region" { type = string }
variable "image" { type = string }
variable "container_port" {
  type    = number
  default = 3000
}
variable "cpu" {
  type    = number
  default = 256
}
variable "memory" {
  type    = number
  default = 512
}
variable "desired_count" {
  type    = number
  default = 2
}
variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }
variable "ingress_security_group_ids" {
  description = "SGs allowed to reach the service port (e.g. the ALB SG)."
  type        = list(string)
  default     = []
}
variable "extra_security_group_ids" {
  description = "Additional SGs attached to the task ENI (e.g. the shared apps SG for DB/Redis access)."
  type        = list(string)
  default     = []
}
variable "environment" {
  type    = map(string)
  default = {}
}
