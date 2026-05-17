output "s3_bucket_name" {
  value = aws_s3_bucket.data-bucket.bucket
  description = "Nombre del bucket s3"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cdn.id
  description = "ID de la distribución de CloudFront"
}
