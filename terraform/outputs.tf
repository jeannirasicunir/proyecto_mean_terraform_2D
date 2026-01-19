output "instance_public_ip" {
  description = "Public IP of backend EC2"
  value       = aws_instance.backend.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of backend EC2"
  value       = aws_instance.backend.public_dns
}

output "application_url" {
  description = "HTTP URL to reach backend"
  value       = "http://${aws_instance.backend.public_ip}:${var.app_port}"
}
