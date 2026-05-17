# Crear Origin Access Control (OAC) para CloudFront
resource "aws_cloudfront_origin_access_control" "oac" {
  name                               = var.oac_name
  description                        = "OAC para el bucket S3"
  origin_access_control_origin_type  = "s3"
  signing_behavior                   = "always"
  signing_protocol                   = "sigv4"
}

# Crear distribución de CloudFront
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"
  # Configuración de dominios alternativos (CNAMEs) para la distribución
  aliases = [var.domain_name]

  origin {
    origin_id   = "s3-origin" # ID del origen, puedes personalizarlo
    domain_name = aws_s3_bucket.data-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.certificate_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.environment
  }

  price_class = "PriceClass_All" # Usa todas las ubicaciones edge

  # No habilitar WAF
  web_acl_id = ""
}