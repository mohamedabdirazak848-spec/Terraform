resource "aws_route53_zone" "primary" {
name = var.domain_name

tags = {
Environment = "production"
}
}

resource "aws_route53_record" "root" {
zone_id = aws_route53_zone.primary.zone_id
name = var.domain_name
type = "A"

alias {
name = aws_lb.load_balancer.dns_name
zone_id = aws_lb.load_balancer.zone_id
evaluate_target_health = true
}
}

resource "aws_route53_record" "www" {
zone_id = aws_route53_zone.primary.zone_id
name = "www.${var.domain_name}"
type = "A"

alias {
name = aws_lb.load_balancer.dns_name
zone_id = aws_lb.load_balancer.zone_id
evaluate_target_health = true
}
}

