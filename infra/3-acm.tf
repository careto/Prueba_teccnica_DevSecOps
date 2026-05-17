# Crear un certificado SSL en ACM
resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Environment = var.environment
  }
}

# Obtener el ID de la zona de Route 53
data "aws_route53_zone" "dns" {
  name = aws_route53_zone.dns.name
}

# Validación del certificado ACM en Route 53 usando for_each
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.dns.id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

# Asociación de validación del certificado ACM
resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn = aws_acm_certificate.certificate.arn

  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}