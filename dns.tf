resource "aws_route53_zone" "primary" {
name = "buildsphere.dev"

tags = {
Environment = "production"
}
}

resource "aws_route53_record" "root" {
zone_id = aws_route53_zone.primary.zone_id
name = "buildsphere.dev"
type = "A"

alias {
name = aws_lb.load_balancer.dns_name
zone_id = aws_lb.load_balancer.zone_id
evaluate_target_health = true
}
}

resource "aws_route53_record" "www" {
zone_id = aws_route53_zone.primary.zone_id
name = "www.buildsphere.dev"
type = "A"

alias {
name = aws_lb.load_balancer.dns_name
zone_id = aws_lb.load_balancer.zone_id
evaluate_target_health = true
}
}

output "name_servers" {
value = aws_route53_zone.primary.name_servers
}