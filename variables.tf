variable "ssh_key_name" {
  description = "Create ssh key name on AWS"
  default     = {}
}

variable "ssh_public_key" {
  description = "Create ssh pub key on AWS"
  default     = {}
}

variable "instance_zone" {
  description = "Create ssh pub key on AWS"
  default     = "eu-central-1a"
}

variable "instance_type" {
  description = "Sets type of instances"
  default     = "t2.micro"
}