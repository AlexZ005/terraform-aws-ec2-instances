data "aws_ami" "ubuntu" {
  owners = ["099720109477"]
  most_recent = "true"
  filter {
    name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

# # 1. Create vpc

 resource "aws_vpc" "prod-vpc" {
   cidr_block = "10.0.0.0/16"
   tags = {
     Name = "production"
   }
 }

# # 2. Create Internet Gateway

 resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.prod-vpc.id
 }
 
# # 3. Create Custom Route Table

 resource "aws_route_table" "prod-route-table" {
   vpc_id = aws_vpc.prod-vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
   }

   route {
     ipv6_cidr_block = "::/0"
     gateway_id      = aws_internet_gateway.gw.id
   }

   tags = {
     Name = "Prod"
   }
 }

# # 4. Create a Subnet 

 resource "aws_subnet" "subnet-1" {
   vpc_id            = aws_vpc.prod-vpc.id
   cidr_block        = "10.0.1.0/24"
   availability_zone = var.instance_zone

   tags = {
     Name = "prod-subnet"
   }
 }

# # 5. Associate subnet with Route Table
 resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.subnet-1.id
   route_table_id = aws_route_table.prod-route-table.id
 }

# # 6. Create Security Group to allow port 22,80,443
 resource "aws_security_group" "allow_web" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
   vpc_id      = aws_vpc.prod-vpc.id

   ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
     description = "All"
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["10.0.1.0/24"]
   }
   
   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "allow_web"
   }
 }

# # 7. Create a network interface with an ip in the subnet that was created in step 4

 resource "aws_network_interface" "web-server-nic" {
   subnet_id       = aws_subnet.subnet-1.id
   private_ips     = ["10.0.1.50"]
   security_groups = [aws_security_group.allow_web.id]
 }
 resource "aws_network_interface" "web-server-nic2" {
   subnet_id       = aws_subnet.subnet-1.id
   private_ips     = ["10.0.1.51"]
   security_groups = [aws_security_group.allow_web.id]
 }

# # 8. Assign an elastic IP to the network interface created in step 7

 resource "aws_eip" "one" {
   vpc                       = true
   network_interface         = aws_network_interface.web-server-nic.id
   associate_with_private_ip = "10.0.1.50"
   depends_on                = [aws_internet_gateway.gw]
 }

 resource "aws_eip" "two" {
   vpc                       = true
   network_interface         = aws_network_interface.web-server-nic2.id
   associate_with_private_ip = "10.0.1.51"
   depends_on                = [aws_internet_gateway.gw]
 }
 
# # 9. Create Ubuntu instances

 resource "aws_instance" "web-server-instance" {
   ami               = "${data.aws_ami.ubuntu.id}"
   instance_type     = var.instance_type
   availability_zone = var.instance_zone
   key_name          = var.ssh_key_name

   network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.web-server-nic.id
   }

   root_block_device {
     volume_type = "gp2"
     volume_size = 20
  }

   tags = {
     Name = "web-server"
   }
 } 
/*
 resource "aws_instance" "web-server-instance2" {
   ami               = "${data.aws_ami.ubuntu.id}"
   instance_type     = var.instance_type
   availability_zone = var.instance_zone
   key_name          = var.ssh_key_name

   network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.web-server-nic2.id
   }

   root_block_device {
     volume_type = "gp2"
     volume_size = 20
  }

   tags = {
     Name = "web-server2"
   }
 }
 */