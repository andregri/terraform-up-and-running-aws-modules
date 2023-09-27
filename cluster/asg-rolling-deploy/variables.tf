variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

variable "min_size" {
  description = "The minimum size of the cluster"
  type        = number
}

variable "custom_tags" {
  description = "Custom tags to set on the instances in ASG"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type        = list(string)
}

variable "target_group_arns" {
  description = "The ARNs of the ELB target groups in which to register instances"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2, ELB"
  type        = string
  default     = "EC2"
}

variable "user_data" {
  description = "The User Data script to run in each Instance at boot"
  type        = string
  default     = ""
}
