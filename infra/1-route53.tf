resource "aws_route53_zone" "dns" {
  name = var.domain_name
  comment = "Zona pública para el dominio ${var.domain_name}"
  tags = {
    env = var.environment
  }
}

# Crear el registro A en Route 53 para apuntar a CloudFront
resource "aws_route53_record" "cloudfront_alias" {
  zone_id = data.aws_route53_zone.dns.zone_id
  name    = var.domain_name  
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}