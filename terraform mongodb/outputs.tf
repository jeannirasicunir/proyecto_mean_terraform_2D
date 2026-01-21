output "mongodb_instance_id" {
  description = "ID of the MongoDB EC2 instance"
  value       = aws_instance.mongodb.id
}

output "mongodb_public_ip" {
  description = "Public IP of the MongoDB EC2 instance"
  value       = aws_instance.mongodb.public_ip
}

output "mongodb_public_dns" {
  description = "Public DNS of the MongoDB EC2 instance"
  value       = aws_instance.mongodb.public_dns
}

output "security_group_id" {
  description = "Security group ID allowing MongoDB and SSH"
  value       = aws_security_group.mongodb_sg.id
}
