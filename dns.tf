resource "aws_route53_zone" "primary" {
  count = var.create_dns_zone ? 1 : 0
  name  = var.domain
}

data "aws_route53_zone" "primary" {
  count = var.create_dns_zone ? 0 : 1
  name  = var.domain
}

locals {
  subdomain   = var.environment_name == "production" ? "" : "${var.environment_name}."
  zone_id = var.create_dns_zone ? aws_route53_zone.primary[0].zone_id : var.zone_id
}


resource "aws_route53_record" "root" {
  zone_id = local.zone_id
  name    = "${local.subdomain}${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}
