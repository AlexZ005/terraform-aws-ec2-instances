output "image_id" {
    value = "${data.aws_ami.ubuntu.id}"
}

output "image_name" {
    value = "${data.aws_ami.ubuntu.name}"
}
 output "server_public_ip" {
   value = aws_eip.one.public_ip
 }

 output "server_public_ip2" {
   value = aws_eip.two.public_ip
 }

# output "server_private_ip" {
#   value = aws_instance.web-server-instance.private_ip

# }

# output "server_id" {
#   value = aws_instance.web-server-instance.id
# }


# resource "<provider>_<resource_type>" "name" {
#     config options.....
#     key = "value"
#     key2 = "another value"
# }
