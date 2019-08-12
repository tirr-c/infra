locals {
  the_ducks_services = ["the-ducks"]
}

resource "aws_iam_policy" "the_ducks_s3" {
  description = "The Ducks S3 policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:Get*",
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersionAcl",
        "s3:PutLifecycleConfiguration",
        "s3:CreateBucket",
        "s3:PutBucketCORS"
      ],
      "Resource": [
        "arn:aws:s3:::the-ducks-uploads",
        "arn:aws:s3:::the-ducks-uploads/*",
        "arn:aws:s3:::the-ducks-discourse-backup",
        "arn:aws:s3:::the-ducks-discourse-backup/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:HeadBucket"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "the_ducks_services" {
  count = length(local.the_ducks_services)

  user       = local.the_ducks_services[count.index]
  policy_arn = aws_iam_policy.the_ducks_s3.arn
}
