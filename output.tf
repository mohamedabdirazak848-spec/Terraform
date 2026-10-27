output "instance_id_1" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server_1.id
}

output "instance_public_ip_1" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server_1.public_ip
}

output "docker_image_1" {
  description = "Docker Image Name"
  value       = var.docker_image_1
}

output "instance_id_2" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server_2.id
}

output "instance_public_ip_2" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server_2.public_ip
}

#output "docker_image_2" {
#description = "Docker Image Name"
#value = var.docker_image_2
#}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.load_balancer.dns_name
}

output "lb_zone_id" {
  value = aws_lb.load_balancer.zone_id
}

output "name_servers" {
  value = var.create_dns_zone ? aws_route53_zone.primary[0].name_servers : data.aws_route53_zone.primary[0].name_servers
}

output "domain_url" {
  value = "https://${var.domain_name}"
}