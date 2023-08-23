variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "custom_tags" {
  description = "Custom tags to set on the instances in ASG"
  type = map(string)
  default = {}
}

variable "db_remote_state_bucket" {
    description = "The name of the S3 bucket for the database's remote state"
    type = string
}

variable "db_remote_state_key" {
    description = "The path for the database's remote state in S3"
    type = string
}