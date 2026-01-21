output "instance_public_ip" {
  description = "Public IP of frontend EC2"
  value       = aws_instance.frontend.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of frontend EC2"
  value       = aws_instance.frontend.public_dns
}

output "application_url" {
  description = "URL to reach the Angular dev server"
  value       = "http://${aws_instance.frontend.public_ip}:4200"
}
