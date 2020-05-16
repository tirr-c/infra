locals {
  web_buckets_us_east_1 = [
    "ames-static.tirr.dev",
    "pcr.tirr.dev",
  ]
  web_buckets_us_west_2 = [
    "image.vbchunguk.me",
    "vbcstatic",
  ]
}

resource "aws_s3_bucket" "web_us_east_1" {
  provider = aws.us_east_1
  for_each = toset(local.web_buckets_us_east_1)

  bucket = each.key
  region = "us-east-1"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "web_us_west_2" {
  provider = aws.us_west_2
  for_each = toset(local.web_buckets_us_west_2)

  bucket = each.key
  region = "us-west-2"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "the_ducks_uploads" {
  bucket = "the-ducks-uploads"
  region = "ap-northeast-1"
  acl    = "public-read"

  lifecycle_rule {
    enabled = true
    id      = "purge_tombstone"
    prefix  = "tombstone/"
    expiration {
      days = 30
    }
  }

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "the_ducks_discourse_backup" {
  bucket = "the-ducks-discourse-backup"
  region = "ap-northeast-1"
  acl    = "private"

  lifecycle_rule {
    id      = "old-backups"
    enabled = true

    transition {
      days          = 28
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_cloudfront_distribution" "the_ducks_uploads" {
  origin {
    domain_name = aws_s3_bucket.the_ducks_uploads.bucket_domain_name
    origin_id   = "S3-the-ducks-uploads"
  }

  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2"
  aliases         = ["uploads.the-ducks.org"]
  price_class     = "PriceClass_100"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    target_origin_id       = "S3-the-ducks-uploads"
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}
