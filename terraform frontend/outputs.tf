output "instance_public_ip" {
  description = "Public IP of frontend EC2"
  value       = aws_instance.frontend.public_ip
}

output "instance_private_ip" {
  description = "Private IP of frontend EC2"
  value       = aws_instance.frontend.private_ip
}

output "instance_public_dns" {
  description = "Public DNS of frontend EC2"
  value       = aws_instance.frontend.public_dns
}

output "application_url" {
  description = "URL to reach the Angular app (via ALB on port 80 when ALB is created, else EC2:4200)"
  value       = var.security_group_id == null && local.create_subnet ? "http://${aws_lb.frontend[0].dns_name}" : "http://${aws_instance.frontend.public_ip}:4200"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer (when ALB is created)"
  value       = var.security_group_id == null && local.create_subnet ? aws_lb.frontend[0].dns_name : null
}
