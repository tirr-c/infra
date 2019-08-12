resource "aws_acm_certificate" "ames_static" {
  provider = aws.us_east_1

  domain_name       = "ames-static.tirr.dev"
  validation_method = "DNS"
}
