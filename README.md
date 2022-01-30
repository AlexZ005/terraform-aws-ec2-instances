Creates only one instance for now, but with dependant resources.  
  
Usage:  

```bash
variable "access_key" {}
variable "secret_key" {}
variable "region" {}

provider "aws" {
access_key = "${var.access_key}"
secret_key = "${var.secret_key}"
region     = "${var.region}"
}

module "ec2-instances" {
    source = "./ec2-instances"
    instance_type = "t2.micro"
    instance_zone = "us-east-1a"
    ssh_key_name = "key_name"
    ssh_public_key = "ssh-rsa [key] [mail]" 
}
